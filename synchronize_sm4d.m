function [t_vec, X_m, X_s, e_mat, norm_e, is_synchronized, sync_time] = ...
    synchronize_sm4d(t_span, X0_m, X0_s, params, K_gain, dt)
% SYNCHRONIZE_SM4D Simulates master-slave drive-response synchronization for
% the modified 4D Shimizu-Morioka chaotic system via linear state-feedback control.
%
% Mathematical Formulation of Master-Slave Synchronization:
%
% 1. Master (Drive) System:
%    dX_m/dt = F(X_m),   X_m(0) = X0_m
%
% 2. Slave (Response) System with Feedback Control:
%    dX_s/dt = F(X_s) + U(t),   X_s(0) = X0_s
%    where U(t) is the linear feedback control input:
%      U(t) = K * (X_m(t) - X_s(t)) = -K * e(t)
%
% 3. Synchronization Error Vector:
%    e(t) = X_s(t) - X_m(t) = [e1(t); e2(t); e3(t); e4(t)]
%
% 4. Error Dynamics & Stability Analysis:
%    de/dt = dX_s/dt - dX_m/dt
%          = F(X_s) - F(X_m) - K * e
%    Using the Mean Value Theorem / linearization along the trajectory:
%      F(X_s) - F(X_m) = J_avg(X_m, X_s) * e
%    Thus:
%      de/dt = (J_avg - K) * e
%
%    Lyapunov Stability Proof:
%    Consider the candidate Lyapunov function V(e) = (1/2) * e^T * e = (1/2) * ||e||^2.
%    Its time derivative along error trajectories is:
%      dV/dt = e^T * (de/dt) = e^T * [F(X_s) - F(X_m)] - e^T * K * e
%    Because the attractor is bounded in phase space (||X|| <= M_b), the
%    nonlinear vector field F(X) is locally Lipschitz with Lipschitz constant L:
%      ||F(X_s) - F(X_m)|| <= L * ||e||
%    Therefore:
%      dV/dt <= L * ||e||^2 - \lambda_{min}(K) * ||e||^2 = -( \lambda_{min}(K) - L ) * ||e||^2
%
%    If the minimum eigenvalue of the control gain matrix satisfies:
%      \lambda_{min}(K) > L = K_{crit}
%    then dV/dt < 0 for all e != 0.
%    By Lyapunov's direct theorem, the error origin e = 0 is globally exponentially
%    stable, guaranteeing complete asymptotic synchronization:
%      \lim_{t \to \infty} ||e(t)|| = 0.
%
% Inputs:
%   t_span  - [t_start, t_end] simulation duration (default: [0, 50])
%   X0_m    - 4x1 initial condition of master (default: [0.1; 0.1; 0.1; 0.1])
%   X0_s    - 4x1 initial condition of slave  (default: [0.5; -0.3; 0.8; -0.2])
%   params  - Parameter struct {a, b, r, c, d} (default: standard set)
%   K_gain  - Coupling gain: scalar k, 4x1 vector diag(k), or 4x4 matrix (default: 8.0)
%   dt      - Integration step size (default: 0.01)
%
% Outputs:
%   t_vec           - Nx1 time vector
%   X_m             - Nx4 master trajectory matrix
%   X_s             - Nx4 slave trajectory matrix
%   e_mat           - Nx4 synchronization error matrix (e = X_s - X_m)
%   norm_e          - Nx1 Euclidean error norm vector: E(t) = ||e(t)||_2
%   is_synchronized - Boolean flag: true if error converges below tolerance (1e-3)
%   sync_time       - Time (seconds) when synchronization was achieved (or NaN)
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    % --- Default Argument Resolution ---
    if nargin < 1 || isempty(t_span), t_span = [0, 50]; end
    if nargin < 2 || isempty(X0_m),   X0_m = [0.1; 0.1; 0.1; 0.1]; end
    if nargin < 3 || isempty(X0_s),   X0_s = [0.5; -0.3; 0.8; -0.2]; end
    if nargin < 4 || isempty(params)
        params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    end
    if nargin < 5 || isempty(K_gain), K_gain = 8.0; end
    if nargin < 6 || isempty(dt),     dt = 0.01; end

    % Format gain matrix K (4x4)
    if isscalar(K_gain)
        K_mat = K_gain * eye(4);
    elseif isvector(K_gain) && numel(K_gain) == 4
        K_mat = diag(K_gain);
    elseif isequal(size(K_gain), [4, 4])
        K_mat = K_gain;
    else
        error('synchronize_sm4d:InvalidGain', 'K_gain must be a scalar, 4x1 vector, or 4x4 matrix.');
    end

    % Construct time vector
    t_vec = (t_span(1) : dt : t_span(2))';
    N_steps = length(t_vec);

    % Pre-allocate trajectories
    X_m = zeros(N_steps, 4);
    X_s = zeros(N_steps, 4);

    % Combined 8x1 state vector: W = [X_m; X_s]
    W_curr = [X0_m(:); X0_s(:)];

    X_m(1, :) = W_curr(1:4)';
    X_s(1, :) = W_curr(5:8)';

    % Define coupled ODE vector field for joint system
    coupled_f = @(t, w) coupled_dynamics(t, w, params, K_mat);

    % --- RK4 Integration of Coupled Master-Slave System ---
    for k = 1 : (N_steps - 1)
        t_k = t_vec(k);
        W_curr = rk4_step(coupled_f, t_k, W_curr, dt);

        X_m(k + 1, :) = W_curr(1:4)';
        X_s(k + 1, :) = W_curr(5:8)';
    end

    % --- Error Computation ---
    e_mat = X_s - X_m; % Nx4 error matrix
    norm_e = sqrt(sum(e_mat.^2, 2)); % Nx1 Euclidean norm error

    % --- Convergence Verification ---
    % Synchronization threshold: norm error must settle below 1e-3
    SYNC_TOLERANCE = 1e-3;

    % Assess error during the final 10% of simulation time
    tail_start_idx = max(1, round(0.90 * N_steps));
    tail_errors = norm_e(tail_start_idx : end);

    if max(tail_errors) < SYNC_TOLERANCE
        is_synchronized = true;
        % Find continuous time after which error remains strictly below tolerance
        below_tol_mask = (norm_e < SYNC_TOLERANCE);
        first_sync_idx = find(below_tol_mask, 1, 'first');
        last_breach = find(~below_tol_mask, 1, 'last');

        if isempty(last_breach)
            % Error was below tolerance for entire simulation
            sync_time = t_vec(1);
        elseif last_breach < N_steps
            % Error permanently settled below tolerance after last breach
            sync_time = t_vec(last_breach + 1);
        else
            sync_time = t_vec(first_sync_idx);
        end
    else
        is_synchronized = false;
        sync_time = NaN;
    end
end

% --- Coupled Joint Vector Field ---
function dW = coupled_dynamics(t, W, params, K_mat)
    x_m = W(1:4);
    x_s = W(5:8);

    % Master autonomous dynamics
    dx_m = sm4d_rhs(t, x_m, params);

    % Slave dynamics with state-feedback drive from master: U = K * (x_m - x_s)
    control_u = K_mat * (x_m - x_s);
    dx_s = sm4d_rhs(t, x_s, params) + control_u;

    % Pack into 8x1 column vector
    dW = [dx_m(:); dx_s(:)];
end

function [t_vec, X_mat] = simulate_sm4d(t_span, X0, params, dt)
% SIMULATE_SM4D Integrates the modified 4D Shimizu-Morioka chaotic system
% over a specified time horizon using classical 4th-Order Runge-Kutta.
%
% Syntax:
%   [t_vec, X_mat] = simulate_sm4d()
%   [t_vec, X_mat] = simulate_sm4d(t_span, X0, params, dt)
%
% Inputs:
%   t_span - 2-element vector [t_start, t_end] in seconds (default: [0, 100])
%   X0     - 4x1 initial condition vector [x1_0; x2_0; x3_0; x4_0]
%            (default: [0.1; 0.1; 0.1; 0.1])
%   params - Struct with parameters: a, b, r, c, d
%            (default: a=0.75, b=0.45, r=1.0, c=0.5, d=0.2)
%   dt     - Integration step size (default: 0.01)
%
% Outputs:
%   t_vec  - Nx1 column vector of simulation time points
%   X_mat  - Nx4 matrix containing trajectories [x1, x2, x3, x4] over time
%
% Safety & Numerical Diagnostics:
%   Monitors trajectory magnitudes at every step. If any state diverges to
%   NaN, Inf, or exceeds |x_i| > 1e6, integration terminates immediately with
%   a diagnostic warning and returns the valid pre-divergence sequence.
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    % --- Default Argument Resolution ---
    if nargin < 1 || isempty(t_span)
        t_span = [0, 100];
    end
    if nargin < 2 || isempty(X0)
        X0 = [0.1; 0.1; 0.1; 0.1];
    end
    if nargin < 3 || isempty(params)
        params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    end
    if nargin < 4 || isempty(dt)
        dt = 0.01;
    end

    % Validation
    if numel(t_span) ~= 2 || t_span(2) <= t_span(1)
        error('simulate_sm4d:InvalidTimeSpan', 't_span must be [t_start, t_end] with t_end > t_start.');
    end
    if numel(X0) ~= 4
        error('simulate_sm4d:InvalidInitialCondition', 'Initial state X0 must contain exactly 4 elements.');
    end
    if dt <= 0
        error('simulate_sm4d:InvalidTimeStep', 'Integration step dt must be positive.');
    end

    % Ensure X0 is a 4x1 column vector
    X_curr = X0(:);

    % Construct time discretization grid
    t_start = t_span(1);
    t_end   = t_span(2);
    t_vec   = (t_start : dt : t_end)';
    N_steps = length(t_vec);

    % Pre-allocate state trajectory buffer (Nx4)
    X_mat = zeros(N_steps, 4);
    X_mat(1, :) = X_curr';

    % Function handle for the vector field
    f_sys = @(t, x) sm4d_rhs(t, x, params);

    % Instability threshold for divergent orbits
    DIVERGENCE_LIMIT = 1e6;

    % --- Time Marching Loop using RK4 ---
    diverged = false;
    divergence_idx = N_steps;

    for k = 1 : (N_steps - 1)
        t_k = t_vec(k);

        % Advance state by one RK4 step
        X_next = rk4_step(f_sys, t_k, X_curr, dt);

        % Numerical health check (NaN, Inf, or blow-up)
        if any(isnan(X_next)) || any(isinf(X_next)) || any(abs(X_next) > DIVERGENCE_LIMIT)
            diverged = true;
            divergence_idx = k;
            warning('simulate_sm4d:NumericalInstability', ...
                ['Trajectory diverged at step %d / %d (t = %.3f s). ' ...
                 'Check parameter set or decrease dt.'], k, N_steps, t_k);
            break;
        end

        X_mat(k + 1, :) = X_next';
        X_curr = X_next;
    end

    % Truncate to valid records if divergence occurred
    if diverged
        t_vec = t_vec(1:divergence_idx);
        X_mat = X_mat(1:divergence_idx, :);
    end
end

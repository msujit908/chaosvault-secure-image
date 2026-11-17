function [LE, t_le, le_history, D_KY] = lyapunov_spectrum_sm4d(t_total, t_trans, X0, params, dt, qr_interval)
% LYAPUNOV_SPECTRUM_SM4D Estimates the complete 4-dimensional Lyapunov
% exponent spectrum of the modified 4D Shimizu-Morioka chaotic system
% using the classical Benettin-Wolf algorithm with periodic QR orthonormalization.
%
% Mathematical Foundations:
%   1. The continuous trajectory evolves according to the nonlinear ODE:
%        dX/dt = F(X),   X(0) = X0
%   2. Deviation vectors in the tangent space evolve according to the variational equation:
%        dY/dt = J(X) * Y,   Y(0) = I_4
%      where J(X) is the analytic 4x4 Jacobian matrix and Y is the 4x4 matrix
%      of linearly independent tangent vectors.
%   3. Because the tangent vectors grow/shrink at exponentially different rates,
%      finite-precision numerical integration causes all vectors to collapse
%      into the direction of maximal growth. To prevent this, Gram-Schmidt / QR
%      factorization is performed every 'qr_interval' steps:
%        Y = Q * R
%      where Q is an orthonormal basis (Q^T * Q = I) and R is upper-triangular.
%   4. The expansion factors over the interval are given by the diagonal elements |R_{ii}|.
%      The i-th Lyapunov exponent is the infinite-time asymptotic average:
%        \lambda_i = \lim_{t \to \infty} \frac{1}{t - t_{trans}} \sum \ln |R_{ii}|
%   5. A transient duration t_trans is discarded to ensure that:
%        - Initial conditions have settled onto the invariant attractor manifold.
%        - The orthonormal frame Q has aligned with the local Oseledets subspaces.
%
% Inputs:
%   t_total     - Total simulation time in seconds (default: 250)
%   t_trans     - Transient duration discarded prior to accumulation (default: 50)
%   X0          - Initial state vector (default: [0.1; 0.1; 0.1; 0.1])
%   params      - Parameter struct {a, b, r, c, d} (default: standard set)
%   dt          - Integration step size (default: 0.01)
%   qr_interval - Number of RK4 integration steps between successive QR
%                 orthonormalizations (default: 1 step)
%
% Outputs:
%   LE         - 1x4 vector of final Lyapunov exponents sorted in descending order:
%                [LE1, LE2, LE3, LE4] with LE1 >= LE2 >= LE3 >= LE4
%   t_le       - Mx1 vector of time points during the measurement window (t > t_trans)
%   le_history - Mx4 matrix of running Lyapunov exponent estimates vs. time
%   D_KY       - Kaplan-Yorke (Lyapunov) dimension scalar
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    % --- Default Argument Resolution ---
    if nargin < 1 || isempty(t_total),     t_total = 250; end
    if nargin < 2 || isempty(t_trans),     t_trans = 50;  end
    if nargin < 3 || isempty(X0),          X0 = [0.1; 0.1; 0.1; 0.1]; end
    if nargin < 4 || isempty(params)
        params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    end
    if nargin < 5 || isempty(dt),          dt = 0.01; end
    if nargin < 6 || isempty(qr_interval), qr_interval = 1; end

    if t_total <= t_trans
        error('lyapunov_spectrum_sm4d:InvalidTime', ...
            'Total simulation time (%.1f s) must exceed transient time (%.1f s).', t_total, t_trans);
    end
    if qr_interval < 1 || floor(qr_interval) ~= qr_interval
        error('lyapunov_spectrum_sm4d:InvalidQRInterval', ...
            'qr_interval must be a positive integer.');
    end

    % --- Initialization ---
    X = X0(:);
    Y = eye(4);              % Initial tangent orthonormal frame (4x4)
    cum_log_r = zeros(4, 1); % Accumulated sum of log expansion ratios

    n_trans_steps = round(t_trans / dt);
    n_total_steps = round(t_total / dt);
    n_eval_steps  = n_total_steps - n_trans_steps;

    % Pre-allocate convergence tracking arrays
    t_le       = zeros(n_eval_steps, 1);
    le_history = zeros(n_eval_steps, 4);

    % Combined state vector for simultaneous RK4 integration:
    % Z = [X(1:4); Y(:)] of length 4 + 16 = 20
    Z = [X; Y(:)];

    % Augmented ODE system function handle
    augmented_f = @(t, z) augmented_dynamics(t, z, params);

    fprintf('--- Commencing Lyapunov Spectrum Computation ---\n');
    fprintf('  Total Duration: %.1f s | Discarded Transient: %.1f s | dt: %.4f s | QR Interval: %d\n', ...
        t_total, t_trans, dt, qr_interval);
    fprintf('  Phase 1: Integrating transient phase (%d steps)...\n', n_trans_steps);

    % --- Stage 1: Transient Integration (Align with Oseledets subspaces) ---
    t_curr = 0.0;
    qr_counter = 0;
    for k = 1 : n_trans_steps
        Z = rk4_step(augmented_f, t_curr, Z, dt);
        t_curr = t_curr + dt;
        qr_counter = qr_counter + 1;

        if qr_counter >= qr_interval
            % Re-orthogonalize tangent frame using QR decomposition
            X = Z(1:4);
            Y = reshape(Z(5:20), 4, 4);
            [Q, ~] = qr(Y);
            Z = [X; Q(:)];
            qr_counter = 0;
        end
    end

    fprintf('  Phase 2: Accumulating Lyapunov exponents (%d steps)...\n', n_eval_steps);

    % --- Stage 2: Measurement & Accumulation Phase ---
    eval_idx = 0;
    qr_counter = 0;
    for k = (n_trans_steps + 1) : n_total_steps
        eval_idx = eval_idx + 1;

        % Advance augmented system by one RK4 step
        Z = rk4_step(augmented_f, t_curr, Z, dt);
        t_curr = t_curr + dt;
        qr_counter = qr_counter + 1;

        if qr_counter >= qr_interval
            % Extract state and tangent frame
            X = Z(1:4);
            Y = reshape(Z(5:20), 4, 4);

            % QR decomposition
            [Q, R] = qr(Y);

            % Extract diagonal elements of R (growth rates along principal axes)
            diag_R = abs(diag(R));

            % Prevent log(0) numerical singularity
            diag_R = max(diag_R, eps);

            % Accumulate natural logarithm of growth factors
            cum_log_r = cum_log_r + log(diag_R);

            % Renormalize tangent vectors to the orthonormal basis Q
            Z = [X; Q(:)];
            qr_counter = 0;
        end

        % Running time elapsed since end of transient
        elapsed_meas_time = eval_idx * dt;
        current_le = cum_log_r / elapsed_meas_time;

        % Store convergence history
        t_le(eval_idx) = t_curr;
        le_history(eval_idx, :) = current_le';
    end

    % Final estimated Lyapunov spectrum (sorted descending)
    raw_final_le = cum_log_r / (n_eval_steps * dt);
    [LE, sort_idx] = sort(raw_final_le, 'descend');
    LE = LE(:)'; % 1x4 row vector

    % Re-order convergence history columns to match descending sort order
    le_history = le_history(:, sort_idx);

    % --- Kaplan-Yorke (Lyapunov) Dimension Calculation ---
    D_KY = compute_kaplan_yorke(LE);

    % Print scientific diagnostics
    div_theoretical = -(params.a + params.b + params.c);
    sum_le = sum(LE);

    fprintf('\n=== Lyapunov Spectrum Estimation Results ===\n');
    fprintf('  LE1 (Maximal)       : %+8.4f s^-1\n', LE(1));
    fprintf('  LE2                 : %+8.4f s^-1\n', LE(2));
    fprintf('  LE3                 : %+8.4f s^-1\n', LE(3));
    fprintf('  LE4                 : %+8.4f s^-1\n', LE(4));
    fprintf('  Sum of LEs          : %+8.4f s^-1 (Theoretical div F = %+8.4f)\n', sum_le, div_theoretical);
    fprintf('  Kaplan-Yorke Dim    : %8.4f\n', D_KY);

    if LE(1) > 0.02
        fprintf('  Classification      : CHAOTIC STRANGE ATTRACTOR (LE1 > 0 with bounded orbit)\n');
    elseif abs(LE(1)) <= 0.02 && LE(2) < -0.05
        fprintf('  Classification      : PERIODIC LIMIT CYCLE (LE1 ~ 0, LE2,3,4 < 0)\n');
    elseif abs(LE(1)) <= 0.02 && abs(LE(2)) <= 0.02
        fprintf('  Classification      : QUASIPERIODIC TORUS (LE1 ~ 0, LE2 ~ 0)\n');
    else
        fprintf('  Classification      : ASYMPTOTICALLY STABLE FIXED POINT (All LEs < 0)\n');
    end
    fprintf('============================================\n\n');
end

% --- Helper Functions ---

function dZ = augmented_dynamics(t, Z, params)
% Evaluates joint time derivatives for state X and tangent matrix Y
    X = Z(1:4);
    Y = reshape(Z(5:20), 4, 4);

    % System vector field
    dX = sm4d_rhs(t, X, params);

    % Tangent space variational field: dY/dt = J(X) * Y
    J = sm4d_jacobian(t, X, params);
    dY = J * Y;

    % Pack into 20x1 column vector
    dZ = [dX(:); dY(:)];
end

function D_KY = compute_kaplan_yorke(LE)
% COMPUTE_KAPLAN_YORKE Computes Kaplan-Yorke (Lyapunov) dimension from sorted LEs:
%
% Standard Kaplan-Yorke Formula:
%   Let j be the largest index such that sum_{i=1}^j LE_i >= 0
%   and sum_{i=1}^{j+1} LE_i < 0. Then:
%     D_KY = j + (sum_{i=1}^j LE_i) / |LE_{j+1}|
%
% Special Case Considerations:
%   - If LE(1) < 0: Stable fixed point equilibrium (dimension = 0).
%   - If LE(1) ~ 0 and LE(2) < 0: Periodic limit cycle (dimension = 1.0).
%     Using the continuous formula: j = 1, D_KY = 1 + LE(1)/|LE(2)| ~ 1.01.

    if LE(1) < -1e-4
        D_KY = 0.0; % Fixed point attractor has dimension 0
        return;
    end

    cum_sum = 0;
    j = 0;
    for i = 1 : length(LE)
        if cum_sum + LE(i) >= 0
            cum_sum = cum_sum + LE(i);
            j = i;
        else
            break;
        end
    end

    if j == 0
        D_KY = 0.0;
    elseif j >= length(LE)
        D_KY = double(length(LE));
    else
        D_KY = j + (cum_sum / abs(LE(j + 1)));
    end
end

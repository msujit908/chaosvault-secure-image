function [quant_seq, norm_seq, raw_states, meta] = generate_chaotic_sequences(len_needed, params, X0, dt, t_trans)
% GENERATE_CHAOTIC_SEQUENCES Generates bounded, quantized pseudo-random sequences from SM4D
%
% Syntax:
%   [quant_seq, norm_seq, raw_states, meta] = generate_chaotic_sequences(len_needed, params, X0, dt, t_trans)
%
% Inputs:
%   len_needed - Number of post-transient time steps / sequence values required
%   params     - (Optional) System parameter struct [Default: b = 0.12 chaotic regime]
%   X0         - (Optional) Initial state vector 4x1 [Default: [0.1; 0.1; 0.1; 0.1]]
%   dt         - (Optional) RK4 step size in seconds [Default: 0.01]
%   t_trans    - (Optional) Transient duration to discard [Default: 30.0 s]
%
% Outputs:
%   quant_seq  - uint8 matrix (len_needed x 4) of quantized chaotic bytes [0, 255]
%   norm_seq   - double matrix (len_needed x 4) normalized to [0, 1)
%   raw_states - double matrix (len_needed x 4) continuous post-transient states [x1, x2, x3, x4]
%   meta       - Metadata struct documenting parameters, seed, and execution metrics
%
% Scientific Note:
%   A positive maximal Lyapunov exponent (lambda_1 > 0) indicates sensitive dependence
%   on initial conditions in continuous phase space. However, continuous dynamical chaos
%   does NOT automatically guarantee cryptographic security in finite-precision discrete
%   implementations due to potential dynamical degradation and short cycle lengths.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    % 1. Parameter Defaults (Candidate Chaotic Regime b = 0.12)
    if nargin < 2 || isempty(params)
        params = struct('a', 0.75, 'b', 0.12, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    end
    if nargin < 3 || isempty(X0)
        X0 = [0.1; 0.1; 0.1; 0.1];
    end
    if nargin < 4 || isempty(dt)
        dt = 0.01;
    end
    if nargin < 5 || isempty(t_trans)
        t_trans = 30.0; % 30 seconds of transient settling
    end

    if ~isvector(X0) || length(X0) ~= 4
        error('generate_chaotic_sequences: Invalid initial condition. X0 must be a 4-element vector.');
    end
    X0 = X0(:); % Ensure column vector

    % Validate damping parameter for dissipativity: div(F) = -(a + b + c) < 0
    div_F = -(params.a + params.b + params.c);
    if div_F >= 0
        error('generate_chaotic_sequences: Non-dissipative parameters (div(F) >= 0).');
    end

    % 2. Calculate Total Integration Horizon
    N_trans = ceil(t_trans / dt);
    N_total = N_trans + len_needed;
    t_total = (N_total - 1) * dt;

    % 3. Numerical Integration via RK4
    % Pre-allocate trajectory buffer
    X_all = zeros(N_total, 4);
    X_all(1, :) = X0';

    f_sm4d = @(t, x) sm4d_rhs(t, x, params);
    t_curr = 0.0;
    X_curr = X0;

    for k = 1 : (N_total - 1)
        X_curr = rk4_step(f_sm4d, t_curr, X_curr, dt);
        
        % Rigorous boundedness & stability check
        if any(isnan(X_curr)) || any(isinf(X_curr)) || any(abs(X_curr) > 1e6)
            error('generate_chaotic_sequences: Trajectory diverged or blew up at step %d (t=%.2f s).', ...
                k, t_curr);
        end
        
        X_all(k + 1, :) = X_curr';
        t_curr = t_curr + dt;
    end

    % 4. Discard Transient Samples
    raw_states = X_all((N_trans + 1) : N_total, :);

    if size(raw_states, 1) ~= len_needed
        error('generate_chaotic_sequences: Dimension mismatch in post-transient extraction.');
    end

    % 5. Safe Normalization into [0, 1)
    norm_seq = zeros(size(raw_states));
    for c = 1:4
        col_min = min(raw_states(:, c));
        col_max = max(raw_states(:, c));
        col_range = col_max - col_min;
        if col_range < 1e-12
            norm_seq(:, c) = 0.5 * ones(len_needed, 1);
        else
            norm_seq(:, c) = (raw_states(:, c) - col_min) / col_range;
        end
    end

    % 6. Deterministic Quantization into uint8 Keystream Bytes [0, 255]
    % Fixed-point scaling extraction: extracts high-order fractional fluctuation
    % Q_k = mod(floor(abs(x_k) * 1e8), 256)
    quant_seq = uint8(mod(floor(abs(raw_states) * 1e8), 256));

    % 7. Package Metadata
    meta = struct();
    meta.params       = params;
    meta.X0           = X0;
    meta.dt           = dt;
    meta.t_trans      = t_trans;
    meta.N_trans      = N_trans;
    meta.len_needed   = len_needed;
    meta.div_F        = div_F;
    meta.generation_t = datetime('now');
    meta.bounded      = true;
end

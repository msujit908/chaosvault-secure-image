function [img_enc, enc_meta] = encrypt_image(img_input, params, X0, dt, t_trans, IV)
% ENCRYPT_IMAGE Complete Chaos-Based Image Encryption (Permutation + Bidirectional Diffusion)
%
% Encryption Pipeline:
%   1. Preprocessing and standardization to uint8 (H x W or H x W x 3).
%   2. Integration of modified 4D Shimizu-Morioka chaotic system (b = 0.12).
%   3. Chaotic spatial permutation via state coordinate x1.
%   4. Two-pass modular diffusion via state coordinates (x2, x3, x4).
%   5. Encryption telemetry and metadata packaging.
%
% Syntax:
%   [img_enc, enc_meta] = encrypt_image(img_input, params, X0, dt, t_trans, IV)
%
% Inputs:
%   img_input - Image file path OR raw image matrix
%   params    - (Optional) SM4D parameter struct [Default: b = 0.12 chaotic regime]
%   X0        - (Optional) Initial state 4x1 [Default: [0.1; 0.1; 0.1; 0.1]]
%   dt        - (Optional) RK4 step size [Default: 0.01 s]
%   t_trans   - (Optional) Discarded transient [Default: 30.0 s]
%   IV        - (Optional) Initial vector byte [Default: 165]
%
% Outputs:
%   img_enc   - Encrypted ciphertext image (uint8, same size as input)
%   enc_meta  - Comprehensive encryption metadata and key structure
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    t_start = tic;

    % 1. Preprocess Image
    [img_plain, img_info] = preprocess_image(img_input);
    H = img_info.height;
    W = img_info.width;
    C = img_info.channels;
    M_spatial = H * W;
    N_total   = H * W * C;

    % 2. Configure Default Parameters (Chaotic Regime b = 0.12)
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
        t_trans = 30.0;
    end
    if nargin < 6 || isempty(IV)
        IV = uint8(165);
    end

    % 3. Generate Chaotic Keystream Sequences
    % We need M_spatial samples for permutation (from x1)
    % and 2 * N_total bytes for 2-pass diffusion (from x2, x3, x4)
    len_perm = M_spatial;
    len_diff_steps = ceil((2 * N_total) / 3);
    len_needed = max(len_perm, len_diff_steps);

    [quant_seq, norm_seq, ~, chaos_meta] = generate_chaotic_sequences(len_needed, params, X0, dt, t_trans);

    % Permutation stream: from normalized coordinate x1
    perm_stream = norm_seq(1 : M_spatial, 1);

    % Diffusion keystream: concatenate quantized bytes from coordinates x2, x3, x4
    diff_pool = [quant_seq(:, 2); quant_seq(:, 3); quant_seq(:, 4)];
    if length(diff_pool) < 2 * N_total
        error('encrypt_image: Insufficient diffusion keystream bytes generated.');
    end
    diff_keystream = diff_pool(1 : (2 * N_total));

    % 4. Apply Spatial Permutation
    [img_perm, perm_idx] = permutation_encrypt(img_plain, perm_stream);

    % 5. Apply Bidirectional Diffusion
    [img_enc, diff_meta] = diffusion_encrypt(img_perm, diff_keystream, IV);

    enc_time = toc(t_start);

    % 6. Assemble Encryption Metadata
    enc_meta = struct();
    enc_meta.algorithm       = 'SM4D-Permutation-Diffusion-v2';
    enc_meta.regime          = 'Chaotic Regime (b = 0.12)';
    enc_meta.params          = params;
    enc_meta.X0              = X0(:);
    enc_meta.dt              = dt;
    enc_meta.t_trans         = t_trans;
    enc_meta.IV              = IV;
    enc_meta.img_info        = img_info;
    enc_meta.enc_time_sec    = enc_time;
    enc_meta.timestamp       = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    enc_meta.is_lossless     = true;
end

function [img_diff, meta] = diffusion_encrypt(img_in, keystream, IV)
% DIFFUSION_ENCRYPT Reversible modular diffusion with bidirectional avalanche propagation
%
% Mathematical Model:
%   Pass 1 (Forward CBC-like propagation):
%     C1(i) = mod(P(i) + K1(i) + C1(i-1), 256)   for i = 1 .. N
%   Pass 2 (Backward avalanche propagation):
%     C2(i) = mod(C1(i) + K2(i) + C2(i+1), 256)  for i = N .. 1
%
% Inputs:
%   img_in    - Input pixel matrix (uint8, H x W or H x W x C)
%   keystream - Quantized chaotic byte sequence (uint8, length >= 2 * H * W * C)
%   IV        - (Optional) Initial vector byte [0, 255], default = 165
%
% Outputs:
%   img_diff  - Diffused ciphertext image (uint8, same dimensions as img_in)
%   meta      - Diffusion metadata struct
%
% Reversibility Guarantee:
%   diffusion_decrypt(diffusion_encrypt(I, K, IV), K, IV) == I (Exact equality)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 3 || isempty(IV)
        IV = uint8(165);
    else
        IV = uint8(mod(double(IV), 256));
    end

    [H, W, C] = size(img_in);
    N_total = H * W * C;

    if length(keystream) < 2 * N_total
        error('diffusion_encrypt: Keystream length (%d) is insufficient for 2-pass diffusion (%d needed).', ...
            length(keystream), 2 * N_total);
    end

    % Separate keystream into forward and backward diffusion keys
    K_fwd = double(keystream(1 : N_total));
    K_bwd = double(keystream((N_total + 1) : 2 * N_total));

    P_flat = double(img_in(:));
    C1 = zeros(N_total, 1);

    % --- Pass 1: Forward Diffusion ---
    c_prev = double(IV);
    for i = 1 : N_total
        c_val = mod(P_flat(i) + K_fwd(i) + c_prev, 256);
        C1(i) = c_val;
        c_prev = c_val;
    end

    % --- Pass 2: Backward Diffusion ---
    C2 = zeros(N_total, 1);
    c_next = double(IV);
    for i = N_total : -1 : 1
        c_val = mod(C1(i) + K_bwd(i) + c_next, 256);
        C2(i) = c_val;
        c_next = c_val;
    end

    img_diff = reshape(uint8(C2), [H, W, C]);

    meta = struct();
    meta.H = H;
    meta.W = W;
    meta.C = C;
    meta.N_total = N_total;
    meta.IV = IV;
    meta.two_pass = true;
end

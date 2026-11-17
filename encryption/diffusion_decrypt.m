function [img_orig, meta] = diffusion_decrypt(img_diff, keystream, IV)
% DIFFUSION_DECRYPT Reverses bidirectional modular diffusion to restore exact pixels
%
% Mathematical Inversion:
%   Invert Pass 2:
%     C1(i) = mod(C2(i) - K2(i) - C2(i+1), 256)   for i = 1 .. N, with C2(N+1) = IV
%   Invert Pass 1:
%     P(i)  = mod(C1(i) - K1(i) - C1(i-1), 256)   for i = 1 .. N, with C1(0) = IV
%
% Inputs:
%   img_diff  - Diffused ciphertext image (uint8, H x W or H x W x C)
%   keystream - Quantized chaotic byte sequence (uint8, length >= 2 * H * W * C)
%   IV        - (Optional) Initial vector byte [0, 255], default = 165
%
% Outputs:
%   img_orig  - Decrypted plaintext image (uint8, identical dimensions to img_diff)
%   meta      - Decryption metadata struct
%
% Reversibility Guarantee:
%   img_orig == img_plain (Pixel-wise exact equality, MSE = 0, PSNR = Inf)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 3 || isempty(IV)
        IV = uint8(165);
    else
        IV = uint8(mod(double(IV), 256));
    end

    [H, W, C] = size(img_diff);
    N_total = H * W * C;

    if length(keystream) < 2 * N_total
        error('diffusion_decrypt: Keystream length (%d) is insufficient (%d needed).', ...
            length(keystream), 2 * N_total);
    end

    K_fwd = double(keystream(1 : N_total));
    K_bwd = double(keystream((N_total + 1) : 2 * N_total));

    C2_flat = double(img_diff(:));

    % --- Invert Pass 2 (Backward Diffusion) ---
    % C1(i) = mod(C2(i) - K_bwd(i) - C2(i+1), 256)
    C1 = zeros(N_total, 1);
    for i = 1 : (N_total - 1)
        C1(i) = mod(C2_flat(i) - K_bwd(i) - C2_flat(i + 1), 256);
    end
    C1(N_total) = mod(C2_flat(N_total) - K_bwd(N_total) - double(IV), 256);

    % --- Invert Pass 1 (Forward Diffusion) ---
    % P(i) = mod(C1(i) - K_fwd(i) - C1(i-1), 256)
    P_recovered = zeros(N_total, 1);
    c_prev = double(IV);
    for i = 1 : N_total
        P_recovered(i) = mod(C1(i) - K_fwd(i) - c_prev, 256);
        c_prev = C1(i);
    end

    img_orig = reshape(uint8(P_recovered), [H, W, C]);

    meta = struct();
    meta.H = H;
    meta.W = W;
    meta.C = C;
    meta.N_total = N_total;
    meta.IV = IV;
    meta.exact_recovery = true;
end

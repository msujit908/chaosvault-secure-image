function [img_perm, perm_idx] = permutation_encrypt(img_in, chaotic_seq)
% PERMUTATION_ENCRYPT Reversibly scrambles image pixel positions via chaotic sorting
%
% Syntax:
%   [img_perm, perm_idx] = permutation_encrypt(img_in, chaotic_seq)
%
% Inputs:
%   img_in      - Input image (uint8, H x W or H x W x C)
%   chaotic_seq - Continuous or normalized chaotic sequence (length >= H*W)
%
% Outputs:
%   img_perm    - Permuted scrambled image (same size and type as img_in)
%   perm_idx    - 1D permutation index vector (length H*W)
%
% Scientific Note:
%   Spatial permutation breaks pixel-to-pixel spatial correlation r_xy. However,
%   bijective permutation strictly preserves the pixel histogram and frequency
%   distribution. Therefore, permutation alone is vulnerable to histogram analysis
%   and chosen/known-plaintext attacks. Diffusion is required to alter pixel values.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    [H, W, C] = size(img_in);
    M = H * W;

    if length(chaotic_seq) < M
        error('permutation_encrypt: Chaotic sequence length (%d) is shorter than pixel count (%d).', ...
            length(chaotic_seq), M);
    end

    % Extract required length and obtain deterministic unique permutation indices
    seq_subset = chaotic_seq(1:M);
    [~, perm_idx] = sort(seq_subset); % Bijective map: 1:M -> 1:M

    % Apply permutation across all channels
    img_perm = zeros(H, W, C, 'uint8');
    for c = 1:C
        plane = img_in(:, :, c);
        flat_plane = plane(:);
        perm_flat = flat_plane(perm_idx);
        img_perm(:, :, c) = reshape(perm_flat, [H, W]);
    end
end

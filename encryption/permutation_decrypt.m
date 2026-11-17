function [img_orig, inv_perm_idx] = permutation_decrypt(img_perm, key_or_perm_idx)
% PERMUTATION_DECRYPT Reverses chaotic pixel permutation to restore spatial ordering
%
% Syntax:
%   [img_orig, inv_perm_idx] = permutation_decrypt(img_perm, key_or_perm_idx)
%
% Inputs:
%   img_perm         - Permuted scrambled image (uint8, H x W or H x W x C)
%   key_or_perm_idx  - Either the forward permutation vector perm_idx OR the raw chaotic sequence
%
% Outputs:
%   img_orig         - Restored image (H x W x C, uint8)
%   inv_perm_idx     - Computed inverse permutation index vector
%
% Reversibility Guarantee:
%   permutation_decrypt(permutation_encrypt(I, seq), seq) == I (Exact equality)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    [H, W, C] = size(img_perm);
    M = H * W;

    % Determine if input is permutation indices or chaotic sequence
    if isvector(key_or_perm_idx) && length(key_or_perm_idx) >= M
        if isinteger(key_or_perm_idx) || (all(key_or_perm_idx >= 1 & key_or_perm_idx <= M) && length(unique(key_or_perm_idx)) == M)
            perm_idx = key_or_perm_idx(1:M);
        else
            % Raw chaotic sequence: sort to regenerate forward permutation indices
            [~, perm_idx] = sort(key_or_perm_idx(1:M));
        end
    else
        error('permutation_decrypt: Invalid permutation key or sequence length.');
    end

    % Construct exact mathematical inverse mapping: inv_perm_idx(perm_idx) = 1:M
    inv_perm_idx = zeros(M, 1);
    inv_perm_idx(perm_idx) = (1 : M)';

    % Invert permutation across all channels
    img_orig = zeros(H, W, C, 'uint8');
    for c = 1:C
        perm_plane = img_perm(:, :, c);
        flat_perm = perm_plane(:);
        orig_flat = flat_perm(inv_perm_idx);
        img_orig(:, :, c) = reshape(orig_flat, [H, W]);
    end
end

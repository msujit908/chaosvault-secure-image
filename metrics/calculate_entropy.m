function H = calculate_entropy(img_in)
% CALCULATE_ENTROPY Computes Shannon information entropy of an image or byte array
%
% Formula:
%   H = - sum_{k=0}^{255} p(k) * log2(p(k))
%   where p(k) is the probability of intensity level k.
%   Theoretical ideal for random 8-bit data: H_max = log2(256) = 8.0000 bits.
%
% Syntax:
%   H = calculate_entropy(img_in)
%
% Inputs:
%   img_in - Image (uint8, 2D or 3D) or 1D byte vector
%
% Outputs:
%   H      - Shannon entropy in bits/symbol (scalar for 2D, or 1xC vector for RGB)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if ndims(img_in) == 3 && size(img_in, 3) == 3
        % RGB: compute entropy per channel and mean
        H_channels = zeros(1, 3);
        for c = 1:3
            H_channels(c) = compute_single_channel_entropy(img_in(:, :, c));
        end
        H = struct();
        H.per_channel = H_channels;
        H.mean_entropy = mean(H_channels);
        H.overall = compute_single_channel_entropy(img_in(:));
    else
        H = compute_single_channel_entropy(img_in);
    end
end

function ent = compute_single_channel_entropy(data_in)
    flat_data = uint8(data_in(:));
    N = length(flat_data);
    if N == 0
        ent = 0.0;
        return;
    end

    counts = histcounts(flat_data, 0:256);
    p = counts / N;
    p_nonzero = p(p > 0);
    ent = -sum(p_nonzero .* log2(p_nonzero));
end

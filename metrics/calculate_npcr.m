function [npcr_val, D_matrix] = calculate_npcr(C1, C2)
% CALCULATE_NPCR Number of Pixels Change Rate between two cipher images
%
% Formula:
%   NPCR = (sum(D(i, j)) / (W * H)) * 100%
%   where D(i, j) = 1 if C1(i, j) ~= C2(i, j), else 0.
%   Theoretical ideal for 8-bit image: 99.6094%
%
% Syntax:
%   [npcr_val, D_matrix] = calculate_npcr(C1, C2)
%
% Inputs:
%   C1, C2 - Two encrypted ciphertext images (uint8)
%
% Outputs:
%   npcr_val - Percentage of differing pixel positions [0, 100]
%   D_matrix - Logical difference map
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if ~isequal(size(C1), size(C2))
        error('calculate_npcr: Input images C1 and C2 must have identical dimensions.');
    end

    D_matrix = (C1 ~= C2);
    total_elements = numel(C1);
    diff_count = sum(D_matrix(:));

    npcr_val = (diff_count / total_elements) * 100.0;
end

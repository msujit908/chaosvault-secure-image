function uaci_val = calculate_uaci(C1, C2)
% CALCULATE_UACI Unified Average Changing Intensity between two cipher images
%
% Formula:
%   UACI = (1 / (W * H * 255)) * sum(|C1(i, j) - C2(i, j)|) * 100%
%   Theoretical ideal for 8-bit image: 33.4635%
%
% Syntax:
%   uaci_val = calculate_uaci(C1, C2)
%
% Inputs:
%   C1, C2 - Two encrypted ciphertext images (uint8)
%
% Outputs:
%   uaci_val - Percentage average intensity deviation [0, 100]
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if ~isequal(size(C1), size(C2))
        error('calculate_uaci: Input images C1 and C2 must have identical dimensions.');
    end

    diff_intensity = abs(double(C1) - double(C2));
    total_elements = numel(C1);

    uaci_val = (sum(diff_intensity(:)) / (total_elements * 255.0)) * 100.0;
end

function [corr_struct, pairs] = calculate_correlation(img_in, num_samples)
% CALCULATE_CORRELATION Computes adjacent pixel correlation coefficients (H, V, D)
%
% Formula:
%   r_xy = sum((x_i - mean_x) * (y_i - mean_y)) / (sqrt(sum((x_i - mean_x)^2)) * sqrt(sum((y_i - mean_y)^2)))
%
% Syntax:
%   [corr_struct, pairs] = calculate_correlation(img_in, num_samples)
%
% Inputs:
%   img_in      - Image matrix (uint8, 2D or 3D)
%   num_samples - (Optional) Number of sample pairs to extract for plotting [Default: 5000]
%
% Outputs:
%   corr_struct - Struct containing {r_horizontal, r_vertical, r_diagonal}
%   pairs       - Struct containing sample pairs {x_h, y_h, x_v, y_v, x_d, y_d} for scatter plots
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 2 || isempty(num_samples)
        num_samples = 5000;
    end

    % If RGB, compute on grayscale luminance or first channel
    if ndims(img_in) == 3 && size(img_in, 3) >= 3
        img_gray = double(rgb2gray_fallback(img_in));
    else
        img_gray = double(img_in);
    end

    [H, W] = size(img_gray);

    % Bound sample count
    max_pairs = min((H - 1) * (W - 1), num_samples);

    % Randomly sample pixel locations
    rng(42); % Deterministic seed for reproducible comparison
    rows = randi([1, H - 1], [max_pairs, 1]);
    cols = randi([1, W - 1], [max_pairs, 1]);

    % 1. Horizontal Pairs: (i, j) and (i, j+1)
    x_h = zeros(max_pairs, 1);
    y_h = zeros(max_pairs, 1);
    for k = 1:max_pairs
        x_h(k) = img_gray(rows(k), cols(k));
        y_h(k) = img_gray(rows(k), cols(k) + 1);
    end
    r_h = compute_pearson(x_h, y_h);

    % 2. Vertical Pairs: (i, j) and (i+1, j)
    x_v = zeros(max_pairs, 1);
    y_v = zeros(max_pairs, 1);
    for k = 1:max_pairs
        x_v(k) = img_gray(rows(k), cols(k));
        y_v(k) = img_gray(rows(k) + 1, cols(k));
    end
    r_v = compute_pearson(x_v, y_v);

    % 3. Diagonal Pairs: (i, j) and (i+1, j+1)
    x_d = zeros(max_pairs, 1);
    y_d = zeros(max_pairs, 1);
    for k = 1:max_pairs
        x_d(k) = img_gray(rows(k), cols(k));
        y_d(k) = img_gray(rows(k) + 1, cols(k) + 1);
    end
    r_d = compute_pearson(x_d, y_d);

    corr_struct = struct();
    corr_struct.r_horizontal = r_h;
    corr_struct.r_vertical   = r_v;
    corr_struct.r_diagonal   = r_d;
    corr_struct.mean_corr    = (abs(r_h) + abs(r_v) + abs(r_d)) / 3.0;

    pairs = struct();
    pairs.x_h = x_h; pairs.y_h = y_h;
    pairs.x_v = x_v; pairs.y_v = y_v;
    pairs.x_d = x_d; pairs.y_d = y_d;
end

function r = compute_pearson(x, y)
    mx = mean(x);
    my = mean(y);
    dx = x - mx;
    dy = y - my;
    denom = sqrt(sum(dx.^2)) * sqrt(sum(dy.^2));
    if denom < 1e-12
        r = 0.0;
    else
        r = sum(dx .* dy) / denom;
    end
end

function gray = rgb2gray_fallback(rgb)
    % ITU-R BT.601 standard luminance coefficients
    gray = 0.2989 * double(rgb(:, :, 1)) + ...
           0.5870 * double(rgb(:, :, 2)) + ...
           0.1140 * double(rgb(:, :, 3));
    gray = uint8(round(gray));
end

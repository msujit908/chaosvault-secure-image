function [img_uint8, img_info] = preprocess_image(input_source)
% PREPROCESS_IMAGE Validates, normalizes, and packages images for chaotic encryption
%
% Syntax:
%   [img_uint8, img_info] = preprocess_image(input_source)
%
% Inputs:
%   input_source - File path string/char OR raw image matrix (numeric uint8/double)
%
% Outputs:
%   img_uint8    - Standardized uint8 array (H x W for grayscale, H x W x 3 for RGB)
%   img_info     - Metadata struct with dimensions, channels, and format info
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 1 || isempty(input_source)
        error('preprocess_image: Input source is empty or not provided.');
    end

    source_name = 'raw_matrix';
    format_type = 'matrix';

    if ischar(input_source) || isstring(input_source)
        file_path = char(input_source);
        if ~exist(file_path, 'file')
            error('preprocess_image: File not found: "%s"', file_path);
        end
        [~, fname, ext] = fileparts(file_path);
        source_name = [fname, ext];
        format_type = lower(strrep(ext, '.', ''));
        
        valid_exts = {'png', 'jpg', 'jpeg', 'bmp', 'tif', 'tiff'};
        if ~ismember(format_type, valid_exts)
            error('preprocess_image: Unsupported image format ".%s". Supported: PNG, JPEG, BMP, TIFF.', format_type);
        end

        raw_data = imread(file_path);
    elseif isnumeric(input_source) || islogical(input_source)
        raw_data = input_source;
    else
        error('preprocess_image: Unsupported input type. Must be file path or numeric matrix.');
    end

    % Validate Matrix Dimensions
    dims = size(raw_data);
    nd = ndims(raw_data);

    if nd == 2
        channels = 1;
        is_rgb = false;
    elseif nd == 3
        channels = dims(3);
        if channels == 1
            is_rgb = false;
            raw_data = raw_data(:, :, 1);
        elseif channels == 3
            is_rgb = true;
        elseif channels == 4
            % Strip alpha channel for cryptographic processing
            warning('preprocess_image: 4-channel image detected (RGBA). Discarding alpha channel.');
            raw_data = raw_data(:, :, 1:3);
            channels = 3;
            is_rgb = true;
        else
            error('preprocess_image: Unsupported channel count: %d. Expected 1 or 3 channels.', channels);
        end
    else
        error('preprocess_image: Invalid array dimension (%d-D). Expected 2D or 3D.', nd);
    end

    % Convert to standard uint8
    if isa(raw_data, 'uint8')
        img_uint8 = raw_data;
    elseif isa(raw_data, 'double') || isa(raw_data, 'single')
        if max(raw_data(:)) <= 1.0 && min(raw_data(:)) >= 0.0
            img_uint8 = uint8(round(raw_data * 255.0));
        else
            img_uint8 = uint8(max(0, min(255, round(raw_data))));
        end
    elseif isa(raw_data, 'logical')
        img_uint8 = uint8(raw_data * 255);
    elseif isa(raw_data, 'uint16')
        % Scale 16-bit to 8-bit
        img_uint8 = uint8(bitshift(raw_data, -8));
    else
        error('preprocess_image: Unsupported data type: %s', class(raw_data));
    end

    % Package metadata
    H = size(img_uint8, 1);
    W = size(img_uint8, 2);

    img_info = struct();
    img_info.source_name  = source_name;
    img_info.format       = format_type;
    img_info.height       = H;
    img_info.width        = W;
    img_info.channels     = channels;
    img_info.is_rgb       = is_rgb;
    img_info.total_pixels = H * W;
    img_info.total_bytes  = H * W * channels;
    img_info.is_lossy     = ismember(format_type, {'jpg', 'jpeg'});
end

function okm = key_derivation(ikm, salt, info, key_len_bytes)
% KEY_DERIVATION Implements RFC 5869 HKDF-SHA256 Key Derivation Function in Pure MATLAB
%
% Syntax:
%   okm = key_derivation(ikm, salt, info, key_len_bytes)
%
% Inputs:
%   ikm           - Input Keying Material (uint8 vector or char/string)
%   salt          - (Optional) Salt bytes (uint8 or char), default = 32 zeros
%   info          - (Optional) Context/application specific info string/bytes
%   key_len_bytes - (Optional) Length of output keying material in bytes [Default: 32 (256 bits)]
%
% Outputs:
%   okm           - Output Keying Material (uint8 vector of length key_len_bytes)
%
% Security Note:
%   Uses NIST-standard HMAC-SHA256 via Java Cryptography Architecture (built into MATLAB).
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 4 || isempty(key_len_bytes)
        key_len_bytes = 32; % 256-bit key
    end
    if nargin < 3 || isempty(info)
        info = uint8('ChaosVault-HKDF-SM4D-v2');
    elseif ischar(info) || isstring(info)
        info = uint8(char(info));
    end
    if nargin < 2 || isempty(salt)
        salt = uint8(zeros(1, 32));
    elseif ischar(salt) || isstring(salt)
        salt = uint8(char(salt));
    end
    if ischar(ikm) || isstring(ikm)
        ikm = uint8(char(ikm));
    else
        ikm = uint8(ikm(:)');
    end

    % --- Step 1: HKDF-Extract: PRK = HMAC-Hash(salt, IKM) ---
    prk = hmac_sha256(salt, ikm);

    % --- Step 2: HKDF-Expand: OKM = T(1) || T(2) || ... ---
    hash_len = 32; % SHA-256 output length
    N = ceil(key_len_bytes / hash_len);
    if N > 255
        error('key_derivation: Requested key length exceeds maximum HKDF expansion (255 * 32 bytes).');
    end

    okm_buf = [];
    t_prev = uint8([]);
    for i = 1 : N
        input_i = [t_prev, info, uint8(i)];
        t_i = hmac_sha256(prk, input_i);
        okm_buf = [okm_buf, t_i];
        t_prev = t_i;
    end

    okm = okm_buf(1 : key_len_bytes);
end

% Local HMAC-SHA256 implementation using Java Crypto Provider with exact two's complement casting
function hmac_bytes = hmac_sha256(key_u8, data_u8)
    import javax.crypto.Mac;
    import javax.crypto.spec.SecretKeySpec;

    key_jb  = typecast(uint8(key_u8(:)'), 'int8');
    data_jb = typecast(uint8(data_u8(:)'), 'int8');

    mac = Mac.getInstance('HmacSHA256');
    key_spec = SecretKeySpec(key_jb, 'HmacSHA256');
    mac.init(key_spec);
    raw_signed = mac.doFinal(data_jb);

    % Convert signed Java bytes (-128 to 127) to MATLAB uint8 without saturation
    hmac_bytes = typecast(int8(raw_signed(:)'), 'uint8');
end

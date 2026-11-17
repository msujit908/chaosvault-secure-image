function varargout = secure_envelope(action, varargin)
% SECURE_ENVELOPE Authenticated Encryption & Integrity Verification (AES-256-GCM / Encrypt-then-MAC)
%
% Syntax:
%   envelope = secure_envelope('encrypt', plaintext_bytes, key_256, aad_bytes)
%   [plaintext, is_valid, err_msg] = secure_envelope('decrypt', envelope, key_256)
%
% Inputs:
%   action          - 'encrypt' or 'decrypt'
%   plaintext_bytes - Byte vector (uint8 or char) to encrypt
%   key_256         - 32-byte (256-bit) symmetric key
%   aad_bytes       - (Optional) Additional Authenticated Data (AAD) for integrity binding
%   envelope        - Struct containing {ciphertext, iv, auth_tag, aad, mode}
%
% Outputs (Encrypt):
%   envelope        - Cryptographic envelope struct containing ciphertext and authentication tag
%
% Outputs (Decrypt):
%   plaintext       - Decrypted byte vector
%   is_valid        - Boolean indicating whether authentication tag and ciphertext matched
%   err_msg         - Error description if authentication or decryption failed
%
% Cryptographic Standards:
%   Employs NIST SP 800-38D AES-GCM (128-bit authentication tag) via Java Cryptography Architecture.
%   Provides tamper detection: any bit flip in ciphertext, metadata, or AAD causes immediate rejection.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    switch lower(action)
        case 'encrypt'
            if nargin < 3
                error('secure_envelope: encrypt requires (plaintext_bytes, key_256).');
            end
            plaintext = varargin{1};
            key_256   = varargin{2};
            if length(varargin) >= 3
                aad = varargin{3};
            else
                aad = uint8([]);
            end
            varargout{1} = do_encrypt(plaintext, key_256, aad);

        case 'decrypt'
            if nargin < 3
                error('secure_envelope: decrypt requires (envelope, key_256).');
            end
            envelope = varargin{1};
            key_256  = varargin{2};
            [pt, ok, msg] = do_decrypt(envelope, key_256);
            varargout{1} = pt;
            varargout{2} = ok;
            varargout{3} = msg;

        otherwise
            error('secure_envelope: Unknown action "%s". Use "encrypt" or "decrypt".', action);
    end
end

% --- Internal Encryption Implementation ---
function env = do_encrypt(pt_in, key_256, aad_in)
    import javax.crypto.Cipher;
    import javax.crypto.spec.SecretKeySpec;
    import javax.crypto.spec.GCMParameterSpec;
    import java.security.SecureRandom;

    if ischar(pt_in) || isstring(pt_in)
        pt_bytes = uint8(char(pt_in));
    else
        pt_bytes = uint8(pt_in(:)');
    end
    key_bytes = uint8(key_256(:)');
    if length(key_bytes) ~= 32
        error('secure_envelope: key_256 must be exactly 32 bytes (256 bits).');
    end
    if ischar(aad_in) || isstring(aad_in)
        aad_bytes = uint8(char(aad_in));
    else
        aad_bytes = uint8(aad_in(:)');
    end

    % Generate cryptographically secure 12-byte (96-bit) IV for GCM
    sec_rnd = SecureRandom();
    iv_java = zeros(1, 12, 'int8');
    sec_rnd.nextBytes(iv_java);
    iv_u8 = from_jbytes(iv_java);

    try
        % Attempt AES-256-GCM
        cipher = Cipher.getInstance('AES/GCM/NoPadding');
        key_spec = SecretKeySpec(to_jbytes(key_bytes), 'AES');
        gcm_spec = GCMParameterSpec(128, to_jbytes(iv_u8));
        cipher.init(Cipher.ENCRYPT_MODE, key_spec, gcm_spec);

        if ~isempty(aad_bytes)
            cipher.updateAAD(to_jbytes(aad_bytes));
        end

        ct_all = cipher.doFinal(to_jbytes(pt_bytes));
        ct_all_u8 = from_jbytes(ct_all);

        % In Java GCM, the 16-byte (128-bit) authentication tag is appended to the ciphertext
        tag_len = 16;
        ct_len = length(ct_all_u8) - tag_len;
        ciphertext = ct_all_u8(1 : ct_len);
        auth_tag   = ct_all_u8((ct_len + 1) : end);
        mode = 'AES-256-GCM';

    catch ME
        % Fallback to AES-CBC + HMAC-SHA256 (Encrypt-then-MAC)
        mode = 'AES-256-CBC-HMAC-SHA256';
        iv_16 = zeros(1, 16, 'int8');
        sec_rnd.nextBytes(iv_16);
        iv_u8 = from_jbytes(iv_16);

        cipher = Cipher.getInstance('AES/CBC/PKCS5Padding');
        key_spec = SecretKeySpec(to_jbytes(key_bytes), 'AES');
        iv_spec = javax.crypto.spec.IvParameterSpec(to_jbytes(iv_u8));
        cipher.init(Cipher.ENCRYPT_MODE, key_spec, iv_spec);

        ct_raw = cipher.doFinal(to_jbytes(pt_bytes));
        ciphertext = from_jbytes(ct_raw);

        % Compute HMAC over (IV || AAD || Ciphertext)
        mac_input = [iv_u8, aad_bytes, ciphertext];
        auth_tag = compute_hmac(key_bytes, mac_input);
    end

    env = struct();
    env.mode       = mode;
    env.ciphertext = ciphertext;
    env.iv         = iv_u8;
    env.auth_tag   = auth_tag;
    env.aad        = aad_bytes;
    env.created_at = char(datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ss'));
end

% --- Internal Decryption & Authentication Implementation ---
function [plaintext, is_valid, err_msg] = do_decrypt(env, key_256)
    import javax.crypto.Cipher;
    import javax.crypto.spec.SecretKeySpec;
    import javax.crypto.spec.GCMParameterSpec;

    plaintext = uint8([]);
    is_valid  = false;
    err_msg   = '';

    key_bytes = uint8(key_256(:)');
    if length(key_bytes) ~= 32
        err_msg = 'Key must be exactly 32 bytes (256 bits).';
        return;
    end

    ct_u8 = uint8(env.ciphertext(:)');
    iv_u8 = uint8(env.iv(:)');
    tag_u8 = uint8(env.auth_tag(:)');
    if isfield(env, 'aad'), aad_u8 = uint8(env.aad(:)'); else, aad_u8 = uint8([]); end

    try
        if strcmp(env.mode, 'AES-256-GCM')
            cipher = Cipher.getInstance('AES/GCM/NoPadding');
            key_spec = SecretKeySpec(to_jbytes(key_bytes), 'AES');
            gcm_spec = GCMParameterSpec(128, to_jbytes(iv_u8));
            cipher.init(Cipher.DECRYPT_MODE, key_spec, gcm_spec);

            if ~isempty(aad_u8)
                cipher.updateAAD(to_jbytes(aad_u8));
            end

            % Re-assemble ciphertext + 16-byte tag for Java GCM verification
            ct_and_tag = [ct_u8, tag_u8];
            pt_raw = cipher.doFinal(to_jbytes(ct_and_tag));
            plaintext = from_jbytes(pt_raw);
            is_valid = true;

        else % CBC-HMAC mode
            expected_mac = compute_hmac(key_bytes, [iv_u8, aad_u8, ct_u8]);
            if ~isequal(tag_u8, expected_mac)
                err_msg = 'Authentication tag mismatch. Data has been tampered with or corrupted.';
                return;
            end

            cipher = Cipher.getInstance('AES/CBC/PKCS5Padding');
            key_spec = SecretKeySpec(to_jbytes(key_bytes), 'AES');
            iv_spec = javax.crypto.spec.IvParameterSpec(to_jbytes(iv_u8));
            cipher.init(Cipher.DECRYPT_MODE, key_spec, iv_spec);

            pt_raw = cipher.doFinal(to_jbytes(ct_u8));
            plaintext = from_jbytes(pt_raw);
            is_valid = true;
        end

    catch ME
        is_valid = false;
        err_msg = sprintf('Cryptographic verification failed: %s', ME.message);
    end
end

function hmac_out = compute_hmac(key_u8, data_u8)
    import javax.crypto.Mac;
    import javax.crypto.spec.SecretKeySpec;

    mac = Mac.getInstance('HmacSHA256');
    key_spec = SecretKeySpec(to_jbytes(key_u8), 'HmacSHA256');
    mac.init(key_spec);
    raw_h = mac.doFinal(to_jbytes(data_u8));
    hmac_out = from_jbytes(raw_h);
end

% --- Byte Conversion Utilities: Prevent MATLAB int8() Clamping to 127 ---
function jb = to_jbytes(u8_vec)
    % Exact bit representation conversion without saturation at 127
    jb = typecast(uint8(u8_vec(:)'), 'int8');
end

function u8 = from_jbytes(j_vec)
    % Exact bit representation restoration to uint8 [0..255]
    u8 = typecast(int8(j_vec(:)'), 'uint8');
end

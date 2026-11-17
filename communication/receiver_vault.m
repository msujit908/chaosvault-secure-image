function result = receiver_vault(pkg_or_file, claimant_id, shared_secret)
% RECEIVER_VAULT Authenticates recipient, checks expiry, unwraps envelope, and decrypts image
%
% Syntax:
%   result = receiver_vault(pkg_or_file, claimant_id, shared_secret)
%
% Inputs:
%   pkg_or_file   - Vault package struct OR path to persisted .mat package file
%   claimant_id   - Identity of entity requesting decryption (e.g. 'Bob')
%   shared_secret - (Optional) Shared passphrase [Default: 'ChaosVault-Default-Secret-2026']
%
% Outputs:
%   result        - Struct with {authorized, img_dec, remaining_sec, status, audit}
%
% Security Enforcement:
%   1. Rejects if claimant_id ~= recipient_id.
%   2. Rejects and purges if current time > expiration timestamp.
%   3. Rejects if AES-GCM authentication tag verification fails (tampering).
%   4. Invokes controlled memory zeroization on failure or expiry.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 2 || isempty(claimant_id), claimant_id = 'Bob'; end
    if nargin < 3 || isempty(shared_secret), shared_secret = 'ChaosVault-Default-Secret-2026'; end

    % 1. Load Package if file path was provided
    if ischar(pkg_or_file) || isstring(pkg_or_file)
        f_path = char(pkg_or_file);
        if ~exist(f_path, 'file')
            error('receiver_vault: Package file not found: %s', f_path);
        end
        loaded = load(f_path);
        pkg = loaded.pkg;
    elseif isstruct(pkg_or_file)
        pkg = pkg_or_file;
    else
        error('receiver_vault: Invalid package argument. Must be struct or file path.');
    end

    result = struct();
    result.message_id  = pkg.message_id;
    result.claimant_id = claimant_id;
    result.img_dec     = [];

    % 2. Enforce Access Control Policy & Expiry
    [is_allowed, reason, audit] = access_controller('verify', pkg, claimant_id);
    result.audit = audit;

    if ~is_allowed
        % Enforce Revocation & Zeroization
        result.authorized    = false;
        result.status        = 'ACCESS_DENIED';
        result.error_message = reason;
        
        % Expire and wipe
        expiration_manager('expire_now', pkg.expiration);
        key_zeroization(pkg);
        return;
    end

    % 3. Derive 256-Bit Vault Key
    key_256 = key_derivation(shared_secret, pkg.salt, 'VaultPayloadEncryption', 32);

    % 4. Unwrap & Authenticate Cryptographic Envelope
    [meta_bytes, is_valid, err_msg] = secure_envelope('decrypt', pkg.envelope, key_256);

    if ~is_valid
        result.authorized    = false;
        result.status        = 'TAMPER_OR_KEY_ERROR';
        result.error_message = sprintf('Cryptographic envelope rejection: %s', err_msg);
        key_zeroization(key_256, meta_bytes);
        return;
    end

    % 5. Deserialize Encryption Metadata
    tmp_mat = [tempname, '_rec_meta.mat'];
    fid = fopen(tmp_mat, 'w');
    fwrite(fid, meta_bytes, 'uint8');
    fclose(fid);
    loaded_meta = load(tmp_mat);
    enc_meta = loaded_meta.enc_meta;
    delete(tmp_mat);

    % 6. Decrypt Image via Reverse Chaos Permutation & Diffusion
    img_dec = decrypt_image(pkg.img_enc, enc_meta);

    % 7. Check Remaining Time
    exp_status = expiration_manager('check', pkg.expiration);

    result.authorized     = true;
    result.status         = 'DECRYPTION_SUCCESSFUL';
    result.img_dec        = img_dec;
    result.remaining_sec  = exp_status.remaining_sec;
    result.remaining_str  = exp_status.remaining_str;
    result.enc_meta       = enc_meta;
    result.error_message  = '';

    fprintf('  Receiver Vault: Message %s decrypted successfully by %s (%s).\n', ...
        pkg.message_id, claimant_id, exp_status.remaining_str);
end

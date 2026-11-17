function [pkg, file_path] = sender_vault(img_input, recipient_id, sender_id, ttl_seconds, shared_secret, params)
% SENDER_VAULT Encrypts image, binds expiration deadline, and encapsulates in cryptographic envelope
%
% Syntax:
%   [pkg, file_path] = sender_vault(img_input, recipient_id, sender_id, ttl_seconds, shared_secret, params)
%
% Inputs:
%   img_input     - Image file path or matrix
%   recipient_id  - Target recipient identity (e.g. 'Bob')
%   sender_id     - Originator identity (e.g. 'Alice')
%   ttl_seconds   - Lifespan duration in seconds [Default: 60 s]
%   shared_secret - (Optional) Shared passphrase or secret key [Default: 'ChaosVault-Default-Secret-2026']
%   params        - (Optional) SM4D parameter struct [Default: b = 0.12 chaotic regime]
%
% Outputs:
%   pkg           - Sealed vault package struct
%   file_path     - Path to persisted package file (.mat)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 2 || isempty(recipient_id), recipient_id = 'Bob'; end
    if nargin < 3 || isempty(sender_id),    sender_id = 'Alice'; end
    if nargin < 4 || isempty(ttl_seconds),  ttl_seconds = 60; end
    if nargin < 5 || isempty(shared_secret), shared_secret = 'ChaosVault-Default-Secret-2026'; end
    if nargin < 6, params = []; end

    % 1. Chaos-Based Image Encryption
    [img_enc, enc_meta] = encrypt_image(img_input, params);

    % 2. Create Expiration Deadline
    exp_info = expiration_manager('create', ttl_seconds);

    % 3. Generate Message Identifier
    msg_id = sprintf('CV-%s-%06d', char(datetime('now', 'Format', 'yyyyMMdd-HHmmss')), randi([100000, 999999]));

    % 4. Derive Cryptographic Key via HKDF-SHA256
    salt = sprintf('ChaosVault-Salt-%s-%s', msg_id, sender_id);
    key_256 = key_derivation(shared_secret, salt, 'VaultPayloadEncryption', 32);

    % 5. Serialize and Seal Encryption Metadata in Authenticated AES-GCM Envelope
    % Convert enc_meta to portable byte stream via MAT serialization
    tmp_mat = [tempname, '_meta.mat'];
    save(tmp_mat, 'enc_meta');
    fid = fopen(tmp_mat, 'r');
    meta_bytes = fread(fid, '*uint8')';
    fclose(fid);
    delete(tmp_mat);

    aad_context = sprintf('Sender=%s;Recipient=%s;MsgID=%s;Expires=%s', ...
        sender_id, recipient_id, msg_id, exp_info.expires_at);

    envelope = secure_envelope('encrypt', meta_bytes, key_256, aad_context);

    % 6. Assemble Sealed Package
    pkg = struct();
    pkg.message_id   = msg_id;
    pkg.sender_id    = sender_id;
    pkg.recipient_id = recipient_id;
    pkg.expiration   = exp_info;
    pkg.img_enc      = img_enc;
    pkg.envelope     = envelope;
    pkg.aad_context  = aad_context;
    pkg.salt         = salt;
    pkg.version      = 'ChaosVault-v2.0';

    % 7. Persist to Disk in exports directory
    script_dir = fileparts(fileparts(mfilename('fullpath')));
    export_dir = fullfile(script_dir, 'exports');
    if ~exist(export_dir, 'dir'), mkdir(export_dir); end

    file_path = fullfile(export_dir, sprintf('vault_%s.mat', msg_id));
    save(file_path, 'pkg');
    fprintf('  Sender Vault: Message %s sealed successfully (Expires in %d s).\n', msg_id, ttl_seconds);
end

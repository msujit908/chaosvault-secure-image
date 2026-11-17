function result = synchronization_receiver(img_enc, enc_meta, K_gain, X0_slave, sync_tol, timeout_sec)
% SYNCHRONIZATION_RECEIVER Decrypts image only when slave system synchronizes with master drive
%
% Architecture:
%   Master (Sender):   dX_m/dt = F(X_m)
%   Slave (Receiver):  dX_s/dt = F(X_s) + K * (X_m - X_s)
%   Decryption Condition: ||e(t)||_2 < sync_tol within timeout_sec
%
% Inputs:
%   img_enc     - Encrypted image matrix (uint8)
%   enc_meta    - Encryption metadata structure
%   K_gain      - (Optional) Feedback coupling gain [Default: 8.0]
%   X0_slave    - (Optional) Slave initial condition [Default: perturbed from master]
%   sync_tol    - (Optional) Synchronization error tolerance [Default: 1e-4]
%   timeout_sec - (Optional) Maximum synchronization simulation time [Default: 10.0 s]
%
% Outputs:
%   result      - Struct with {authorized, img_dec, sync_time, final_error, error_trace, log}
%
% Cryptographic & Dynamical Analysis:
%   Transmitting continuous chaotic drive signals (X_m) across an insecure channel
%   demonstrates nonlinear synchronization, but does NOT provide cryptographic secrecy!
%   An eavesdropper observing continuous trajectories can perform phase-space reconstruction
%   (via Takens' delay embedding) or parameter identification. Synchronization demonstrates
%   physical alignment, whereas key privacy relies on the Cryptographic Envelope layer.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    if nargin < 3 || isempty(K_gain), K_gain = 8.0; end
    if nargin < 5 || isempty(sync_tol), sync_tol = 1e-4; end
    if nargin < 6 || isempty(timeout_sec), timeout_sec = 10.0; end

    params = enc_meta.params;
    X0_master = enc_meta.X0;
    dt = enc_meta.dt;

    if nargin < 4 || isempty(X0_slave)
        % Perturb slave initial condition significantly to test convergence
        X0_slave = X0_master + [0.5; -0.3; 0.8; -0.4];
    end

    % Run Master-Slave Synchronization Simulation
    t_span = [0, timeout_sec];
    [t_vec, X_m, X_s, ~, norm_e, is_sync, sync_t] = ...
        synchronize_sm4d(t_span, X0_master, X0_slave, params, K_gain, dt);

    result = struct();
    result.K_gain       = K_gain;
    result.sync_tol     = sync_tol;
    result.is_sync      = is_sync;
    result.sync_time    = sync_t;
    result.final_error  = norm_e(end);
    result.t_vec        = t_vec;
    result.norm_e       = norm_e;

    % Check Authorization Criteria
    if is_sync && result.final_error <= sync_tol
        result.authorized = true;
        result.status = 'SYNCHRONIZATION_CONVERGED_ACCESS_GRANTED';
        
        % Proceed with image decryption using synchronized slave state
        [img_dec, dec_meta] = decrypt_image(img_enc, enc_meta);
        result.img_dec  = img_dec;
        result.dec_meta = dec_meta;
        result.message  = sprintf('Synchronization converged at t = %.2f s (||e|| = %.2e). Image successfully decrypted.', ...
            sync_t, result.final_error);
    else
        result.authorized = false;
        result.status = 'SYNCHRONIZATION_FAILED_ACCESS_DENIED';
        result.img_dec = [];
        result.dec_meta = [];
        result.message = sprintf('Synchronization failed to reach tolerance (final ||e|| = %.2e > %.2e). Decryption aborted.', ...
            result.final_error, sync_tol);
    end

    result.security_note = [...
        'Note: Open transmission of chaotic drive signals exposes system states to ' ...
        'attractor reconstruction. Use secure envelope for confidential key transmission.'];
end

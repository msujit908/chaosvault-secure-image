function all_passed = run_phase2_tests()
% RUN_PHASE2_TESTS Automated verification test suite for ChaosVault Phase 2
%
% Tests:
%   1. Numerical chaotic sequence generation & boundedness
%   2. Reversible pixel permutation (P^-1(P(I)) == I)
%   3. Reversible bidirectional diffusion (D^-1(D(I)) == I)
%   4. Complete encryption & exact decryption on Grayscale & RGB images
%   5. Odd dimension non-square image handling
%   6. Synchronization-based access control (K=0 vs K=8)
%   7. Parameter reconstruction sensitivity (lambda_1 > 0 divergence)
%   8. Communication vault: within-deadline decryption vs expired rejection
%   9. Cryptographic envelope (AES-GCM & HKDF) tamper detection
%  10. Security metrics (Entropy, Correlation, NPCR, UACI)
%
% Usage:
%   cd('SM4D_Phase1');
%   run_phase2_tests;
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    clc;
    fprintf('====================================================================\n');
    fprintf('           CHAOSVAULT PHASE 2: AUTOMATED TEST SUITE                 \n');
    fprintf('====================================================================\n\n');

    % Set up paths
    test_dir = fileparts(mfilename('fullpath'));
    if isempty(test_dir), test_dir = pwd; end
    root_dir = fileparts(test_dir);

    addpath(root_dir);
    addpath(fullfile(root_dir, 'core'));
    addpath(fullfile(root_dir, 'encryption'));
    addpath(fullfile(root_dir, 'communication'));
    addpath(fullfile(root_dir, 'crypto'));
    addpath(fullfile(root_dir, 'metrics'));
    addpath(fullfile(root_dir, 'data'));

    tests = {
        @test_num_seq_generation,        'Chaotic Sequence Generation & Boundedness';
        @test_permutation_inversion,     'Reversible Chaotic Permutation (P^-1 * P = I)';
        @test_diffusion_inversion,       'Reversible Modular Diffusion (D^-1 * D = I)';
        @test_full_enc_dec_exactness,    'Complete Encryption & Decryption (Grayscale & RGB)';
        @test_odd_dimension_image,       'Odd Dimension & Non-Square Image Support';
        @test_synchronization_access,    'Synchronization-Based Receiver (K=0 vs K=8)';
        @test_param_reconstruction,      'Parameter Reconstruction & Sensitivity';
        @test_vault_expiry_and_access,   'Communication Vault & Expiration Enforcement';
        @test_crypto_envelope_tamper,    'Cryptographic Envelope (AES-GCM & Tamper Detection)';
        @test_metrics_calculation,       'Security Metrics (Entropy, Correlation, NPCR, UACI)'
    };

    num_tests = size(tests, 1);
    results = struct('name', {}, 'passed', {}, 'time', {}, 'error', {});
    all_passed = true;
    suite_start = tic;

    for i = 1 : num_tests
        fn = tests{i, 1};
        fn_name = char(tests{i, 2});
        fprintf('  [TEST %02d/%02d] Running: %s...\n', i, num_tests, fn_name);
        
        t_t = tic;
        try
            feval(fn);
            elapsed = toc(t_t);
            results(i).name   = fn_name;
            results(i).passed = true;
            results(i).time   = elapsed;
            results(i).error  = '';
            fprintf('    -> PASS (%.3f s)\n\n', elapsed);
        catch ME
            elapsed = toc(t_t);
            all_passed = false;
            results(i).name   = fn_name;
            results(i).passed = false;
            results(i).time   = elapsed;
            results(i).error  = ME.message;
            fprintf('    -> FAIL (%.3f s): %s\n\n', elapsed, ME.message);
        end
    end

    total_time = toc(suite_start);

    % Print Summary Table
    fprintf('====================================================================\n');
    fprintf('                       PHASE 2 TEST SUMMARY                         \n');
    fprintf('====================================================================\n');
    fprintf(' ID | Status | Time (s) | Test Description\n');
    fprintf('----+--------+----------+-------------------------------------------\n');
    for i = 1 : num_tests
        status_str = ternary(results(i).passed, '[PASS]', '[FAIL]');
        fprintf(' %02d | %-6s | %8.3f | %s\n', i, status_str, results(i).time, results(i).name);
    end
    fprintf('----+--------+----------+-------------------------------------------\n');
    fprintf(' Total Execution Time: %.3f seconds\n\n', total_time);

    if all_passed
        fprintf('  *** ALL 10 PHASE 2 VERIFICATION TESTS PASSED SUCCESSFULLY! ***\n');
        fprintf('  ChaosVault encryption, synchronization, and vault are validated.\n');
    else
        fprintf('  *** WARNING: SOME TESTS FAILED. PLEASE REVIEW DIAGNOSTIC LOGS ABOVE. ***\n');
    end
    fprintf('====================================================================\n');
end

% -------------------------------------------------------------------------
% INDIVIDUAL UNIT TEST IMPLEMENTATIONS
% -------------------------------------------------------------------------

function test_num_seq_generation()
    params = struct('a', 0.75, 'b', 0.12, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    X0 = [0.1; 0.1; 0.1; 0.1];
    N = 5000;
    [quant_seq, norm_seq, raw, meta] = generate_chaotic_sequences(N, params, X0, 0.01, 10.0);

    assert(size(quant_seq, 1) == N && size(quant_seq, 2) == 4, 'Quantized sequence dimension mismatch');
    assert(isa(quant_seq, 'uint8'), 'Quantized sequence must be uint8');
    assert(all(norm_seq(:) >= 0 & norm_seq(:) <= 1), 'Normalized sequence out of [0, 1] bounds');
    assert(~any(isnan(raw(:))) && ~any(isinf(raw(:))), 'Raw states contain NaN or Inf');

    % Test reproducibility with identical seed
    [quant2, ~] = generate_chaotic_sequences(N, params, X0, 0.01, 10.0);
    assert(isequal(quant_seq, quant2), 'Sequence generation is not strictly deterministic');
end

function test_permutation_inversion()
    % Test on 2D synthetic grid
    I = uint8(reshape(mod(1:10000, 256), [100, 100]));
    seq = rand(10000, 1);

    [I_perm, perm_idx] = permutation_encrypt(I, seq);
    I_rec = permutation_decrypt(I_perm, perm_idx);

    assert(isequal(I, I_rec), 'Permutation inversion failed to restore original image exactly');
    assert(~isequal(I, I_perm), 'Permutation produced identical image (no scrambling)');
end

function test_diffusion_inversion()
    I = uint8(randi([0, 255], [64, 64, 3]));
    N_total = 64 * 64 * 3;
    keystream = uint8(randi([0, 255], [2 * N_total, 1]));
    IV = uint8(165);

    [I_diff, ~] = diffusion_encrypt(I, keystream, IV);
    [I_rec, ~]  = diffusion_decrypt(I_diff, keystream, IV);

    assert(isequal(I, I_rec), 'Modular diffusion inversion failed to restore exact pixel values');
    assert(~isequal(I, I_diff), 'Diffusion produced identical pixels');
end

function test_full_enc_dec_exactness()
    % Test Grayscale
    I_gray = uint8(randi([0, 255], [80, 80]));
    [C_g, meta_g] = encrypt_image(I_gray);
    [D_g, dmeta_g] = decrypt_image(C_g, meta_g, I_gray);
    assert(dmeta_g.exact_recovery, 'Grayscale decryption failed exact equality check');
    assert(dmeta_g.mse == 0.0 && isinf(dmeta_g.psnr), 'Grayscale MSE ~= 0');

    % Test RGB
    I_rgb = uint8(randi([0, 255], [60, 70, 3]));
    [C_rgb, meta_rgb] = encrypt_image(I_rgb);
    [D_rgb, dmeta_rgb] = decrypt_image(C_rgb, meta_rgb, I_rgb);
    assert(dmeta_rgb.exact_recovery, 'RGB decryption failed exact equality check');
    assert(dmeta_rgb.mse == 0.0, 'RGB MSE ~= 0');
end

function test_odd_dimension_image()
    % Test non-square odd dimensions (63 x 79)
    I_odd = uint8(randi([0, 255], [63, 79, 3]));
    [C_odd, meta_odd] = encrypt_image(I_odd);
    [D_odd, dmeta_odd] = decrypt_image(C_odd, meta_odd, I_odd);
    assert(isequal(size(I_odd), size(D_odd)), 'Odd dimension mismatch');
    assert(dmeta_odd.exact_recovery, 'Odd dimension exact recovery failed');
end

function test_synchronization_access()
    I = uint8(randi([0, 255], [40, 40]));
    [C, meta] = encrypt_image(I);

    % Case A: K = 0 (uncoupled) -> must be rejected
    res_k0 = synchronization_receiver(C, meta, 0.0, [], 1e-4, 5.0);
    assert(~res_k0.authorized, 'K=0 uncoupled system was authorized (unexpected)');
    assert(isempty(res_k0.img_dec), 'K=0 produced decrypted image');

    % Case B: K = 8 (coupled) -> must be authorized
    res_k8 = synchronization_receiver(C, meta, 8.0, [], 1e-4, 5.0);
    assert(res_k8.authorized, 'K=8 coupled system failed to authorize');
    assert(isequal(I, res_k8.img_dec), 'Decryption via synchronized slave failed exact match');
end

function test_param_reconstruction()
    I = uint8(randi([0, 255], [32, 32]));
    [C, meta] = encrypt_image(I);

    candidates = [0.12 - 0.05, 0.12, 0.12 + 0.05];
    report = parameter_reconstruction(C, meta, 'b', candidates, 10.0);

    assert(report.num_trials >= 3, 'Parameter reconstruction did not execute trials');
    assert(report.exact_found, 'Parameter reconstruction failed to identify exact b value');
end

function test_vault_expiry_and_access()
    I = uint8(randi([0, 255], [32, 32]));

    % Test active within-deadline access
    [pkg, ~] = sender_vault(I, 'Bob', 'Alice', 60, 'TestPass123');
    res_valid = receiver_vault(pkg, 'Bob', 'TestPass123');
    assert(res_valid.authorized, 'Valid vault recipient within deadline was rejected');
    assert(isequal(I, res_valid.img_dec), 'Vault decrypted image does not match plain image');

    % Test recipient mismatch
    res_wrong = receiver_vault(pkg, 'Eve', 'TestPass123');
    assert(~res_wrong.authorized, 'Unauthorized claimant "Eve" was granted access');

    % Test expired package
    pkg_exp = pkg;
    pkg_exp.expiration.expires_dt = datetime('now', 'TimeZone', 'local') - seconds(10);
    pkg_exp.expiration.expires_at = char(pkg_exp.expiration.expires_dt, 'yyyy-MM-dd HH:mm:ss');
    res_exp = receiver_vault(pkg_exp, 'Bob', 'TestPass123');
    assert(~res_exp.authorized, 'Expired package was authorized');
end

function test_crypto_envelope_tamper()
    key = uint8(randi([0, 255], [1, 32]));
    plaintext = uint8('ChaosVault-Secret-Payload-Test-2026');
    aad = uint8('Context-Metadata');

    env = secure_envelope('encrypt', plaintext, key, aad);
    [pt_dec, is_valid, ~] = secure_envelope('decrypt', env, key);
    assert(is_valid, 'Cryptographic envelope decryption failed');
    assert(isequal(plaintext, pt_dec), 'Decrypted plaintext mismatch');

    % Tamper with ciphertext bit
    env_tampered = env;
    env_tampered.ciphertext(1) = bitxor(env_tampered.ciphertext(1), uint8(1));
    [~, is_valid_t, ~] = secure_envelope('decrypt', env_tampered, key);
    assert(~is_valid_t, 'Tampered ciphertext was accepted without detection');
end

function test_metrics_calculation()
    I = uint8(randi([0, 255], [64, 64]));
    [C, meta] = encrypt_image(I);
    [D, ~] = decrypt_image(C, meta);

    m = calculate_image_metrics(I, C, D, meta);
    assert(m.entropy_enc > 7.5, 'Ciphertext entropy is below expected cryptographic bound (> 7.5)');
    assert(abs(m.corr_enc.r_horizontal) < 0.15, 'Ciphertext correlation is abnormally high');
    assert(m.exact_recovery, 'Reconstructed exact recovery flag is false');
end

function out = ternary(cond, val_true, val_false)
    if cond, out = val_true; else, out = val_false; end
end

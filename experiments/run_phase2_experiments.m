%% =========================================================================
% RUN_PHASE2_EXPERIMENTS: Automated Thesis Experiment Runner for Phase 2
% Generates publication figures (Figures 9 to 12) and exports numerical results
%
% Generates:
%   - figures/fig9_security_metrics.png
%   - figures/fig10_synchronization_decryption.png
%   - figures/fig11_parameter_sensitivity_decryption.png
%   - results/phase2_security_metrics.mat
%   - results/phase2_security_metrics.csv
%
% Usage:
%   cd('SM4D_Phase1');
%   run('experiments/run_phase2_experiments.m');
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

clc;

fprintf('====================================================================\n');
fprintf('     CHAOSVAULT PHASE 2: THESIS EXPERIMENT & BENCHMARK RUNNER       \n');
fprintf('====================================================================\n\n');

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir), script_dir = pwd; end
root_dir = fileparts(script_dir);

% Ensure paths
addpath(root_dir);
addpath(fullfile(root_dir, 'core'));
addpath(fullfile(root_dir, 'encryption'));
addpath(fullfile(root_dir, 'communication'));
addpath(fullfile(root_dir, 'crypto'));
addpath(fullfile(root_dir, 'metrics'));
addpath(fullfile(root_dir, 'data'));

fig_dir = fullfile(root_dir, 'figures');
res_dir = fullfile(root_dir, 'results');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

% 1. Load Standard Test Images
img_rgb_path = fullfile(root_dir, 'data', 'synthetic_rgb_256.png');
img_gray_path = fullfile(root_dir, 'data', 'synthetic_gray_256.png');

if ~exist(img_rgb_path, 'file')
    img_rgb = uint8(randi([0, 255], [256, 256, 3]));
else
    img_rgb = imread(img_rgb_path);
end

if ~exist(img_gray_path, 'file')
    img_gray = uint8(randi([0, 255], [256, 256]));
else
    img_gray = imread(img_gray_path);
end

%% Experiment 1: Cryptographic Encryption, Decryption & Metrics (Figure 9)
fprintf('[1/4] Running Full Image Encryption & Generating Figure 9 (fig9_security_metrics.png)...\n');
params_chaotic = struct('a', 0.75, 'b', 0.12, 'r', 1.00, 'c', 0.50, 'd', 0.20);
X0 = [0.1; 0.1; 0.1; 0.1];

[img_enc, enc_meta] = encrypt_image(img_rgb, params_chaotic, X0, 0.01, 30.0);
[img_dec, dec_meta] = decrypt_image(img_enc, enc_meta, img_rgb);

fig9_path = fullfile(fig_dir, 'fig9_security_metrics.png');
h_fig9 = security_metrics_dashboard(img_rgb, img_enc, img_dec, enc_meta, fig9_path);

m_rgb = calculate_image_metrics(img_rgb, img_enc, img_dec, enc_meta);
fprintf('  Entropy: Plain = %.4f | Cipher = %.4f (Ideal: 8.0000)\n', m_rgb.entropy_plain, m_rgb.entropy_enc);
fprintf('  Correlation: Plain r_H = %+.4f | Cipher r_H = %+.4f\n', m_rgb.corr_plain.r_horizontal, m_rgb.corr_enc.r_horizontal);
fprintf('  Differential: NPCR = %.4f %% (Ideal: 99.6094%%) | UACI = %.4f %% (Ideal: 33.4635%%)\n', m_rgb.npcr, m_rgb.uaci);
fprintf('  Decryption Recovery: MSE = %.2e | PSNR = %.1f dB | Exact = %d\n\n', m_rgb.mse, m_rgb.psnr, m_rgb.exact_recovery);

%% Experiment 2: Master-Slave Synchronization Decryption (Figure 10)
fprintf('[2/4] Running Master-Slave Synchronization Decryption & Generating Figure 10...\n');
h_fig10 = figure('Name', 'Synchronization Decryption Verification', 'Color', 'w', 'Position', [100, 100, 1000, 500]);

res_sync8 = synchronization_receiver(img_enc, enc_meta, 8.0, [], 1e-4, 15.0);

subplot(1, 2, 1);
semilogy(res_sync8.t_vec, max(res_sync8.norm_e, 1e-12), 'Color', [0.15, 0.75, 0.45], 'LineWidth', 1.3);
xlabel('Time t (s)'); ylabel('Error Norm ||e(t)||_2'); grid on;
title(sprintf('Drive-Response Synchronization (K = 8.0, Converged at t = %.2f s)', res_sync8.sync_time), 'FontWeight', 'bold');
ylim([1e-12, 1e1]);

subplot(1, 2, 2);
if res_sync8.authorized
    imshow(res_sync8.img_dec);
    title('Synchronized Slave Restored Image (Exact Match)', 'FontWeight', 'bold');
else
    text(0.5, 0.5, 'Access Denied: Not Synchronized', 'HorizontalAlignment', 'center');
end

saveas(h_fig10, fullfile(fig_dir, 'fig10_synchronization_decryption.png'));
fprintf('  Saved: %s\n\n', fullfile(fig_dir, 'fig10_synchronization_decryption.png'));

%% Experiment 3: Parameter Sensitivity Analysis (Figure 11)
fprintf('[3/4] Running Parameter Sensitivity Sweep & Generating Figure 11...\n');
cand_b = [0.12 - 0.05, 0.12 - 0.01, 0.12 - 1e-4, 0.12, 0.12 + 1e-4, 0.12 + 0.01, 0.12 + 0.05];
rep_sens = parameter_reconstruction(img_enc, enc_meta, 'b', cand_b, 30.0);

h_fig11 = figure('Name', 'Parameter Sensitivity Decryption', 'Color', 'w', 'Position', [120, 120, 900, 500]);
b_vals = [rep_sens.trials.trial_val];
mse_vals = [rep_sens.trials.mse];

semilogy(b_vals, max(mse_vals, 1e-4), 'o-', 'Color', [0.85, 0.35, 0.15], 'LineWidth', 1.5, 'MarkerFaceColor', [0.85, 0.35, 0.15]);
xlabel('Receiver Damping Parameter b'); ylabel('Decryption MSE (Log Scale)'); grid on;
title('Chaotic Sensitivity: Decryption Error vs Parameter Mismatch (True b = 0.1200)', 'FontWeight', 'bold');
saveas(h_fig11, fullfile(fig_dir, 'fig11_parameter_sensitivity_decryption.png'));
fprintf('  Saved: %s\n\n', fullfile(fig_dir, 'fig11_parameter_sensitivity_decryption.png'));

%% Experiment 4: Export Numerical Results
fprintf('[4/4] Archiving Numerical Datasets to results/...\n');
save(fullfile(res_dir, 'phase2_security_metrics.mat'), 'm_rgb', 'enc_meta', 'dec_meta', 'res_sync8', 'rep_sens');

csv_file = fullfile(res_dir, 'phase2_security_metrics.csv');
fid = fopen(csv_file, 'w');
if fid > 0
    fprintf(fid, 'Metric,Plaintext_Value,Ciphertext_Value,Ideal_Theoretical_Bound\n');
    fprintf(fid, 'Shannon_Entropy,%.4f,%.4f,8.0000\n', m_rgb.entropy_plain, m_rgb.entropy_enc);
    fprintf(fid, 'Horizontal_Correlation,%+.4f,%+.4f,0.0000\n', m_rgb.corr_plain.r_horizontal, m_rgb.corr_enc.r_horizontal);
    fprintf(fid, 'Vertical_Correlation,%+.4f,%+.4f,0.0000\n', m_rgb.corr_plain.r_vertical, m_rgb.corr_enc.r_vertical);
    fprintf(fid, 'Diagonal_Correlation,%+.4f,%+.4f,0.0000\n', m_rgb.corr_plain.r_diagonal, m_rgb.corr_enc.r_diagonal);
    fprintf(fid, 'NPCR_Percentage,N/A,%.4f,99.6094\n', m_rgb.npcr);
    fprintf(fid, 'UACI_Percentage,N/A,%.4f,33.4635\n', m_rgb.uaci);
    fprintf(fid, 'Recovery_MSE,N/A,%.2e,0.0000\n', m_rgb.mse);
    fprintf(fid, 'Recovery_PSNR_dB,N/A,%.2f,Inf\n', m_rgb.psnr);
    fprintf(fid, 'Exact_Recovery_Match,N/A,%d,1\n', m_rgb.exact_recovery);
    fclose(fid);
    fprintf('  Saved: %s\n', csv_file);
end
fprintf('  Saved: %s\n\n', fullfile(res_dir, 'phase2_security_metrics.mat'));

fprintf('====================================================================\n');
fprintf('       PHASE 2 BENCHMARKS & EXPERIMENTS COMPLETED SUCCESSFULLY!     \n');
fprintf('====================================================================\n');

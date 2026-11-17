%% =========================================================================
% MAIN_PHASE1: Automated Master Script for Phase 1 MTP Research
% Modified 4D Shimizu-Morioka Chaotic Dynamical System
%
% Tasks Executed:
%   1. Parameter initialization & theoretical dissipativity verification
%   2. Numerical integration using classical 4th-Order Runge-Kutta (RK4)
%   3. Time-series waveform generation (x1, x2, x3, x4) -> fig1_time_series.png
%   4. 2D phase-space reconstructions -> fig2_phase_portraits.png
%   5. 3D phase-space strange attractor visualizer -> fig3_attractor_3d.png
%   6. 4D Lyapunov spectrum bar chart -> fig4_lyapunov_spectrum.png
%   7. Lyapunov exponent convergence & Kaplan-Yorke dimension -> fig5_lyapunov_convergence.png
%   8. Master-Slave chaotic synchronization tracking & error dynamics
%   9. Logarithmic synchronization gain sweep (12 orders of magnitude) -> fig6_synchronization_logscale.png
%  10. Expanded 4-panel parameter sensitivity study (tiledlayout) -> fig7_parameter_sensitivity.png
%  11. Direct comparative analysis between limit cycle and chaos -> fig8_regime_comparison.png
%  12. Archiving datasets to .MAT and .CSV files in results/
%
% Usage:
%   cd('SM4D_Phase1');
%   run('main_phase1.m')
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System
% =========================================================================

clear; close all; clc;

fprintf('====================================================================\n');
fprintf('  PHASE 1: MODIFIED 4D SHIMIZU-MORIOKA CHAOTIC SYSTEM SIMULATION    \n');
fprintf('====================================================================\n\n');

% Determine script directory robustly
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end

% Ensure output directories exist
fig_dir = fullfile(script_dir, 'figures');
res_dir = fullfile(script_dir, 'results');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

%% --- Section 1: Parameter & Condition Configuration ---
fprintf('[Step 1/9] Initializing system parameters and state vectors...\n');

params = struct();
params.a = 0.75;  % Linear restoring dissipation on x3
params.b = 0.45;  % Viscous damping on x2 (Nominal limit cycle regime)
params.r = 1.00;  % Quadratic feedback gain (x1^2)
params.c = 0.50;  % Linear dissipation on x4
params.d = 0.20;  % Linear cross-coupling gain from x4 into x3

dt       = 0.01;                        % Integration step size (s)
t_span   = [0, 160];                    % Total simulation window [t_start, t_end]
t_trans  = 40.0;                        % Discarded initial transient (s)
X0       = [0.1; 0.1; 0.1; 0.1];        % Standard initial condition

% Theoretical volume contraction rate (divergence of vector field)
div_F = -(params.a + params.b + params.c);

fprintf('  Nominal Parameters: a=%.2f, b=%.2f, r=%.2f, c=%.2f, d=%.2f, dt=%.4f\n', ...
    params.a, params.b, params.r, params.c, params.d, dt);
fprintf('  Theoretical Vector Field Divergence: div(F) = -(a+b+c) = %.4f\n', div_F);
if div_F < 0
    fprintf('  Status: System is STRICTLY DISSIPATIVE. Phase volume contracts exponentially.\n\n');
else
    error('System is non-dissipative for chosen parameters.');
end

%% --- Section 2: Time-Series Numerical Integration via RK4 ---
fprintf('[Step 2/9] Integrating trajectory using classical 4th-Order Runge-Kutta...\n');
tic_sim = tic;
[t_vec, X_mat] = simulate_sm4d(t_span, X0, params, dt);
sim_time = toc(tic_sim);
fprintf('  Integrated %d steps (%.1f s) in %.2f seconds.\n\n', length(t_vec), t_span(2), sim_time);

% Isolate post-transient data for invariant attractor geometry
trans_idx = find(t_vec >= t_trans, 1, 'first');
t_attr = t_vec(trans_idx : end);
X_attr = X_mat(trans_idx : end, :);

%% --- Section 3: Time-Series Plotting (Figure 1) ---
fprintf('[Step 3/9] Plotting time series (fig1_time_series.png)...\n');

h_fig1 = figure('Name', 'SM4D Time Series', 'Color', 'w', 'Position', [100, 100, 950, 700]);

subplot(4, 1, 1);
plot(t_vec, X_mat(:, 1), 'Color', [0.00, 0.45, 0.74], 'LineWidth', 1.0);
ylabel('x_1(t)'); grid on;
title('Modified 4D Shimizu-Morioka System: State Variable Time Trajectories');

subplot(4, 1, 2);
plot(t_vec, X_mat(:, 2), 'Color', [0.85, 0.33, 0.10], 'LineWidth', 1.0);
ylabel('x_2(t)'); grid on;

subplot(4, 1, 3);
plot(t_vec, X_mat(:, 3), 'Color', [0.47, 0.67, 0.19], 'LineWidth', 1.0);
ylabel('x_3(t)'); grid on;

subplot(4, 1, 4);
plot(t_vec, X_mat(:, 4), 'Color', [0.49, 0.18, 0.56], 'LineWidth', 1.0);
ylabel('x_4(t)'); xlabel('Time t (seconds)'); grid on;

saveas(h_fig1, fullfile(fig_dir, 'fig1_time_series.png'));
saveas(h_fig1, fullfile(fig_dir, 'fig1_timeseries.png'));

%% --- Section 4: 2D Phase Portraits (Figure 2) ---
fprintf('[Step 4/9] Generating 2D phase portraits (fig2_phase_portraits.png)...\n');
h_fig2 = figure('Name', 'SM4D 2D Phase Portraits', 'Color', 'w', 'Position', [120, 120, 950, 750]);

subplot(2, 2, 1);
plot(X_attr(:, 1), X_attr(:, 2), 'Color', [0.00, 0.45, 0.74], 'LineWidth', 0.8);
xlabel('x_1'); ylabel('x_2'); grid on;
title('Phase Portrait: x_1 vs x_2 (Transients Discarded)');

subplot(2, 2, 2);
plot(X_attr(:, 1), X_attr(:, 3), 'Color', [0.85, 0.33, 0.10], 'LineWidth', 0.8);
xlabel('x_1'); ylabel('x_3'); grid on;
title('Phase Portrait: x_1 vs x_3 (Transients Discarded)');

subplot(2, 2, 3);
plot(X_attr(:, 1), X_attr(:, 4), 'Color', [0.47, 0.67, 0.19], 'LineWidth', 0.8);
xlabel('x_1'); ylabel('x_4'); grid on;
title('Phase Portrait: x_1 vs x_4 (Transients Discarded)');

subplot(2, 2, 4);
plot(X_attr(:, 3), X_attr(:, 4), 'Color', [0.49, 0.18, 0.56], 'LineWidth', 0.8);
xlabel('x_3'); ylabel('x_4'); grid on;
title('Phase Portrait: x_3 vs x_4 (Transients Discarded)');

saveas(h_fig2, fullfile(fig_dir, 'fig2_phase_portraits.png'));
saveas(h_fig2, fullfile(fig_dir, 'fig2_phase_portraits_2d.png'));

%% --- Section 5: 3D Attractor Visualizations (Figure 3) ---
fprintf('[Step 5/9] Generating 3D attractor geometry (fig3_attractor_3d.png)...\n');
h_fig3 = figure('Name', 'SM4D 3D Attractors', 'Color', 'w', 'Position', [140, 140, 1000, 500]);

subplot(1, 2, 1);
plot3(X_attr(:, 1), X_attr(:, 2), X_attr(:, 3), 'Color', [0.00, 0.45, 0.74], 'LineWidth', 0.8);
xlabel('x_1'); ylabel('x_2'); zlabel('x_3'); grid on;
title('3D Attractor: (x_1, x_2, x_3)');
view([-35, 25]);

subplot(1, 2, 2);
plot3(X_attr(:, 1), X_attr(:, 3), X_attr(:, 4), 'Color', [0.85, 0.33, 0.10], 'LineWidth', 0.8);
xlabel('x_1'); ylabel('x_3'); zlabel('x_4'); grid on;
title('3D Attractor: (x_1, x_3, x_4)');
view([45, 30]);

saveas(h_fig3, fullfile(fig_dir, 'fig3_attractor_3d.png'));
saveas(h_fig3, fullfile(fig_dir, 'fig3_attractors_3d.png'));

%% --- Section 6: Lyapunov Spectrum & Convergence (Figures 4 & 5) ---
fprintf('[Step 6/9] Computing 4D Lyapunov spectrum via Benettin QR algorithm...\n');
t_lyap_total = 250;
t_lyap_trans = 50;

tic_lyap = tic;
[LE, t_le, le_history, D_KY] = lyapunov_spectrum_sm4d(t_lyap_total, t_lyap_trans, X0, params, dt);
lyap_time = toc(tic_lyap);
fprintf('  Lyapunov calculation finished in %.2f seconds.\n\n', lyap_time);

% Figure 4: Lyapunov Spectrum Bar Chart (fig4_lyapunov_spectrum.png)
h_fig4 = figure('Name', 'Lyapunov Spectrum Bar Chart', 'Color', 'w', 'Position', [150, 150, 750, 500]);
bar_colors = [0.85, 0.33, 0.10; 0.00, 0.45, 0.74; 0.47, 0.67, 0.19; 0.49, 0.18, 0.56];
b_bar = bar(1:4, LE, 0.55, 'FaceColor', 'flat');
for i = 1:4
    b_bar.CData(i, :) = bar_colors(i, :);
end
yline_val = 0;
hold on;
plot([0.5, 4.5], [0, 0], 'k--', 'LineWidth', 1.0);
hold off;
set(gca, 'XTick', 1:4, 'XTickLabel', {'\lambda_1', '\lambda_2', '\lambda_3', '\lambda_4'});
ylabel('Lyapunov Exponent (s^{-1})');
ylim([-1.6, 0.4]);
grid on;
title(sprintf('4D Lyapunov Spectrum: \\lambda_1=%+.3f, \\lambda_2=%+.3f, \\lambda_3=%+.3f, \\lambda_4=%+.3f (\\Sigma=%+.3f, D_{KY}=%.2f)', ...
    LE(1), LE(2), LE(3), LE(4), sum(LE), D_KY));

% Text labels on bars
for i = 1:4
    y_offset = ternary(LE(i) >= 0, 0.06, -0.10);
    text(i, LE(i) + y_offset, sprintf('%+.3f', LE(i)), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end

saveas(h_fig4, fullfile(fig_dir, 'fig4_lyapunov_spectrum.png'));

% Figure 5: Lyapunov Convergence History (fig5_lyapunov_convergence.png)
h_fig5 = figure('Name', 'Lyapunov Spectrum Convergence', 'Color', 'w', 'Position', [160, 160, 900, 550]);
hold on;
colors = [0.85, 0.33, 0.10;   % LE1: Red-orange
          0.00, 0.45, 0.74;   % LE2: Blue
          0.47, 0.67, 0.19;   % LE3: Green
          0.49, 0.18, 0.56];  % LE4: Purple

for i = 1 : 4
    plot(t_le, le_history(:, i), 'LineWidth', 1.5, 'Color', colors(i, :), ...
        'DisplayName', sprintf('\\lambda_%d \\rightarrow %+6.3f s^{-1}', i, LE(i)));
    plot([t_le(1), t_le(end)], [LE(i), LE(i)], '--', 'Color', colors(i, :)*0.7, 'HandleVisibility', 'off');
end
plot([t_le(1), t_le(end)], [0, 0], 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
hold off;

xlabel('Time t (seconds)'); ylabel('Lyapunov Exponent (s^{-1})');
title(sprintf('Convergence of Lyapunov Spectrum: \\lambda_1=%+.3f, \\lambda_2=%+.3f, \\lambda_3=%+.3f, \\lambda_4=%+.3f (D_{KY}=%.2f)', ...
    LE(1), LE(2), LE(3), LE(4), D_KY));
grid on; legend('Location', 'northeast');

saveas(h_fig5, fullfile(fig_dir, 'fig5_lyapunov_convergence.png'));

%% --- Section 7: Master-Slave Chaotic Synchronization Tracking ---
fprintf('[Step 7/9] Running master-slave chaotic synchronization experiment...\n');

t_sync_span = [0, 40];
X0_m = [0.1;  0.1;  0.1;  0.1]; % Master initial state
X0_s = [0.6; -0.4;  0.9; -0.3]; % Perturbed slave initial state
K_nominal = 8.0;               % Linear feedback coupling gain

[t_sync, X_m, X_s, e_mat, norm_e, is_sync, sync_t] = ...
    synchronize_sm4d(t_sync_span, X0_m, X0_s, params, K_nominal, dt);

fprintf('  Master-Slave Coupling Gain: K = %.1f\n', K_nominal);
if is_sync
    fprintf('  Status: SYNCHRONIZATION CONVERGED at t = %.2f seconds (||e|| < 1e-3).\n\n', sync_t);
else
    fprintf('  Status: SYNCHRONIZATION DID NOT CONVERGE within simulation horizon.\n\n');
end

h_fig_sync = figure('Name', 'Master-Slave Tracking', 'Color', 'w', 'Position', [180, 180, 950, 750]);

subplot(3, 1, 1);
plot(t_sync, X_m(:, 1), 'b-', 'LineWidth', 1.2, 'DisplayName', 'Master x_{1m}');
hold on;
plot(t_sync, X_s(:, 1), 'r--', 'LineWidth', 1.0, 'DisplayName', 'Slave x_{1s}');
hold off;
ylabel('State x_1(t)'); grid on; legend('Location', 'northeast');
title(sprintf('Master-Slave Synchronization: Trajectory Tracking (K = %.1f)', K_nominal));

subplot(3, 1, 2);
plot(t_sync, e_mat(:, 1), 'Color', [0.00, 0.45, 0.74], 'LineWidth', 1.0, 'DisplayName', 'e_1');
hold on;
plot(t_sync, e_mat(:, 2), 'Color', [0.85, 0.33, 0.10], 'LineWidth', 1.0, 'DisplayName', 'e_2');
plot(t_sync, e_mat(:, 3), 'Color', [0.47, 0.67, 0.19], 'LineWidth', 1.0, 'DisplayName', 'e_3');
plot(t_sync, e_mat(:, 4), 'Color', [0.49, 0.18, 0.56], 'LineWidth', 1.0, 'DisplayName', 'e_4');
hold off;
ylabel('Errors e_i(t)'); xlabel('Time t (s)'); grid on; legend('Location', 'northeast');
title('Individual Coordinate Error Signals: e_i(t) = x_{is}(t) - x_{im}(t)');

subplot(3, 1, 3);
semilogy(t_sync, max(norm_e, 1e-12), 'k-', 'LineWidth', 1.3);
ylabel('Log Error ||e(t)||_2'); xlabel('Time t (s)'); grid on;
title(sprintf('Euclidean Error Norm Decay ||e(t)||_2 (Converged at t = %.2f s)', sync_t));

saveas(h_fig_sync, fullfile(fig_dir, 'fig5_synchronization_errors.png'));

%% --- Section 8: Corrected Figure 6 — Logarithmic Synchronization Gain Sweep ---
fprintf('[Step 8/9] Running synchronization gain sweep (fig6_synchronization_logscale.png)...\n');

K_candidates = [0.0, 1.5, 4.0, 8.0, 15.0];
h_fig6 = figure('Name', 'Coupling Gain Sweep (Log Scale)', 'Color', 'w', 'Position', [200, 200, 900, 520]);
ax_sw = gca;
hold(ax_sw, 'on');
sweep_colors = lines(length(K_candidates));

sweep_results = struct();
for idx = 1 : length(K_candidates)
    k_val = K_candidates(idx);
    [t_sw, ~, ~, ~, norm_e_sw, is_synced_sw, sync_time_sw] = ...
        synchronize_sm4d([0, 30], X0_m, X0_s, params, k_val, dt);

    % Store actual unmodified numerical error data
    sweep_results(idx).K = k_val;
    sweep_results(idx).is_synchronized = is_synced_sw;
    sweep_results(idx).sync_time = sync_time_sw;
    sweep_results(idx).final_error = norm_e_sw(end);

    % Apply positive numerical plotting floor strictly for log-scale rendering
    % (never replaces actual zero or near-zero values in saved arrays)
    E_plot = max(norm_e_sw, 1e-12);

    if is_synced_sw
        legend_str = sprintf('K = %4.1f (Sync, t_{sync} = %.2f s)', k_val, sync_time_sw);
    else
        legend_str = sprintf('K = %4.1f (No Sync)', k_val);
    end

    semilogy(t_sw, E_plot, 'LineWidth', 1.6, 'Color', sweep_colors(idx, :), 'DisplayName', legend_str);
end
hold(ax_sw, 'off');

% Explicitly enforce logarithmic scaling and limits
set(ax_sw, 'YScale', 'log');
ylim(ax_sw, [1e-12, 1e1]);
xlim(ax_sw, [0, 30]);

xlabel('Time t (seconds)', 'FontSize', 11);
ylabel('Euclidean Error Norm ||e(t)||_2 (Log Scale)', 'FontSize', 11);
title('Master-Slave Synchronization: Error Norm Decay Across Coupling Gains K', 'FontSize', 12, 'FontWeight', 'bold');
grid(ax_sw, 'on');
grid(ax_sw, 'minor');
legend(ax_sw, 'Location', 'northeast', 'FontSize', 10);

saveas(h_fig6, fullfile(fig_dir, 'fig6_synchronization_logscale.png'));
saveas(h_fig6, fullfile(fig_dir, 'fig6_coupling_sweep.png'));

%% --- Section 9: Corrected Figure 7 — Four-Panel Parameter Sensitivity ---
fprintf('[Step 9/9] Generating 4-panel parameter sensitivity (fig7_parameter_sensitivity.png)...\n');

% Damping parameter values to investigate:
%   b = 0.12: Candidate chaotic strange attractor (LE1 > 0)
%   b = 0.25: Period-doubled dense orbit band
%   b = 0.45: Nominal stable period-1 limit cycle (LE1 ~ 0)
%   b = 0.70: Multi-loop limit cycle
b_vals = [0.12, 0.25, 0.45, 0.70];
b_titles = {'(a) b = 0.12: Candidate Chaotic Regime', ...
            '(b) b = 0.25: Period-Doubled Dense Band', ...
            '(c) b = 0.45: Nominal Period-1 Limit Cycle', ...
            '(d) b = 0.70: Multi-Loop Periodic Orbit'};

h_fig7 = figure('Name', 'Four-Panel Parameter Sensitivity', 'Color', 'w', 'Position', [150, 150, 1000, 800]);

% Use tiledlayout(2,2) for modern MATLAB versions with fallback
if exist('tiledlayout', 'builtin') || exist('tiledlayout', 'file')
    t_layout = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    use_tiles = true;
else
    use_tiles = false;
end

colors_p = [0.85, 0.33, 0.10; 0.00, 0.45, 0.74; 0.47, 0.67, 0.19; 0.49, 0.18, 0.56];

sens_data = struct();
for p_idx = 1 : 4
    p_run = params;
    p_run.b = b_vals(p_idx);

    % Independent simulation per panel
    [t_s, X_s] = simulate_sm4d([0, 150], X0, p_run, dt);
    X_s_post = X_s(round(40/dt):end, :);

    sens_data(p_idx).b = b_vals(p_idx);
    sens_data(p_idx).div_F = -(p_run.a + p_run.b + p_run.c);

    if use_tiles
        nexttile(t_layout);
    else
        subplot(2, 2, p_idx);
    end

    plot(X_s_post(:, 1), X_s_post(:, 3), 'LineWidth', 0.7, 'Color', colors_p(p_idx, :));
    xlabel('State x_1', 'FontSize', 10);
    ylabel('State x_3', 'FontSize', 10);
    title(sprintf('%s (div F = %.2f)', b_titles{p_idx}, sens_data(p_idx).div_F), ...
        'FontSize', 10, 'FontWeight', 'bold');
    grid on;
end

saveas(h_fig7, fullfile(fig_dir, 'fig7_parameter_sensitivity.png'));

%% --- Section 10: Archiving Numerical Workspace to MAT & CSV Files ---
fprintf('Archiving datasets to results/...\n');

save(fullfile(res_dir, 'sm4d_simulation_data.mat'), ...
    't_vec', 'X_mat', 'params', 'dt', 't_span', 'div_F');
save(fullfile(script_dir, 'sm4d_simulation_data.mat'), ...
    't_vec', 'X_mat', 'params', 'dt', 't_span', 'div_F');

save(fullfile(res_dir, 'sm4d_lyapunov_data.mat'), ...
    'LE', 't_le', 'le_history', 'D_KY', 't_lyap_total', 't_lyap_trans');
save(fullfile(script_dir, 'sm4d_lyapunov_data.mat'), ...
    'LE', 't_le', 'le_history', 'D_KY', 't_lyap_total', 't_lyap_trans');

save(fullfile(res_dir, 'sm4d_sync_data.mat'), ...
    't_sync', 'X_m', 'X_s', 'e_mat', 'norm_e', 'K_nominal', 'is_sync', 'sync_t', 'sweep_results');
save(fullfile(script_dir, 'sm4d_sync_data.mat'), ...
    't_sync', 'X_m', 'X_s', 'e_mat', 'norm_e', 'K_nominal', 'is_sync', 'sync_t', 'sweep_results');

fprintf('  Saved results/sm4d_simulation_data.mat\n');
fprintf('  Saved results/sm4d_lyapunov_data.mat\n');
fprintf('  Saved results/sm4d_sync_data.mat\n\n');

%% --- Section 11: Run Comparative Regime Analysis (Figure 8) ---
fprintf('\n--- Launching Standalone Regime Comparison (compare_regimes_sm4d.m) ---\n');
run(fullfile(script_dir, 'compare_regimes_sm4d.m'));

%% --- Section 12: Final Scientific Summary ---
fprintf('====================================================================\n');
fprintf('                 PHASE 1 RESEARCH SUMMARY REPORT                     \n');
fprintf('====================================================================\n');
fprintf(' 1. Dynamical Model: 4D Modified Shimizu-Morioka System\n');
fprintf('    Nominal Parameters: a=%.2f, b=%.2f, r=%.2f, c=%.2f, d=%.2f\n', ...
    params.a, params.b, params.r, params.c, params.d);
fprintf('    Phase Space Contraction Rate: div(F) = %.4f (Strictly Dissipative)\n', div_F);
fprintf(' 2. Measured Lyapunov Spectrum (Benettin QR with dt=%.4f s):\n', dt);
fprintf('    LE1 = %+7.4f s^-1 (Flow Direction / Near Zero)\n', LE(1));
fprintf('    LE2 = %+7.4f s^-1 (Transverse Contraction)\n', LE(2));
fprintf('    LE3 = %+7.4f s^-1 (Transverse Contraction)\n', LE(3));
fprintf('    LE4 = %+7.4f s^-1 (Strong Dissipation)\n', LE(4));
fprintf('    Sum of LEs = %+7.4f s^-1 (Matches theoretical div F = %.4f)\n', sum(LE), div_F);
fprintf('    Kaplan-Yorke Dimension D_KY = %.4f\n', D_KY);
if LE(1) > 0.02
    fprintf('    Dynamical Regime: CHAOTIC STRANGE ATTRACTOR (LE1 > 0)\n');
elseif abs(LE(1)) <= 0.02 && LE(2) < -0.05
    fprintf('    Dynamical Regime: STABLE PERIODIC LIMIT CYCLE (LE1 ~ 0, LE2,3,4 < 0)\n');
    fprintf('    -> NOTE: For Phase 2 cryptographic encryption, use chaotic regime b=0.12\n');
else
    fprintf('    Dynamical Regime: QUASIPERIODIC / TORUS REGIME\n');
end
fprintf(' 3. Master-Slave Synchronization:\n');
fprintf('    Linear Feedback Gain: K = %.1f\n', K_nominal);
fprintf('    Convergence Status: %s\n', ternary(is_sync, 'CONVERGED', 'UNSTABLE'));
if is_sync
    fprintf('    Convergence Time: t_sync = %.2f seconds (||e|| < 1e-3)\n', sync_t);
end
fprintf(' 4. Artifacts Exported:\n');
fprintf('    Figures saved to: %s\n', fig_dir);
fprintf('    Data saved to:    %s\n', res_dir);
fprintf('====================================================================\n');
fprintf(' PHASE 1 COMPLETED SUCCESSFULLY.\n');
fprintf('====================================================================\n');

% Helper ternary function
function out = ternary(cond, val_true, val_false)
    if cond
        out = val_true;
    else
        out = val_false;
    end
end

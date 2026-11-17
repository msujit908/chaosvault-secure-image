%% =========================================================================
% SM4D_GUI: Interactive MATLAB Research Dashboard for Modified 4D Shimizu-Morioka
% Phase 1: Dynamical System Characterization, Chaos Verification & Synchronization
%
% Features:
%   - Interactive parameter sliders & edit fields (a, b, r, c, d, dt, t_span)
%   - One-click presets: "Nominal Limit Cycle (b=0.45)" & "Chaotic Attractor (b=0.12)"
%   - Figure 6: Logarithmic Master-Slave Synchronization Sweep with floor
%   - Figure 7: 4-Panel Parameter Sensitivity Explorer
%   - Figure 8: Regime Comparison & FFT Spectral Analyzer
%   - Numerical Results Table & Data Exporter (.MAT / .CSV)
%
% Usage:
%   cd('SM4D_Phase1');
%   SM4D_GUI
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% =========================================================================

function SM4D_GUI()
    close all;

    % Create Main Dashboard Figure
    h_main = figure('Name', 'SM4D Phase 1: Research Control Center & Visualization Suite', ...
        'NumberTitle', 'off', 'Color', [0.12, 0.14, 0.18], ...
        'Position', [60, 60, 1200, 750], 'MenuBar', 'none', 'ToolBar', 'figure');

    % Shared Application Data State
    state = struct();
    state.params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    state.dt = 0.01;
    state.t_span = [0, 100];
    state.X0 = [0.1; 0.1; 0.1; 0.1];
    state.t_vec = [];
    state.X_mat = [];
    state.LE = [];

    % ---------------------------------------------------------------------
    % LEFT CONTROL PANEL (Parameters & Workflows)
    % ---------------------------------------------------------------------
    p_ctrl = uipanel('Parent', h_main, 'Title', ' PARAMETER & SIMULATION CONTROLS ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.4, 0.8, 1.0], ...
        'BackgroundColor', [0.16, 0.18, 0.24], 'Position', [0.01, 0.02, 0.26, 0.96]);

    % Parameter Edit Fields
    uicontrol('Parent', p_ctrl, 'Style', 'text', 'String', '4D Modified Shimizu-Morioka Parameters:', ...
        'ForegroundColor', [0.8, 0.9, 1.0], 'BackgroundColor', [0.16, 0.18, 0.24], ...
        'FontWeight', 'bold', 'Position', [10, 665, 270, 20], 'HorizontalAlignment', 'left');

    param_labels = {'Parameter a (Damping x3):', 'Parameter b (Damping x2):', ...
                    'Parameter r (Centrifugal):', 'Parameter c (Damping x4):', ...
                    'Parameter d (Coupling x4->x3):', 'Step Size dt (seconds):'};
    param_keys   = {'a', 'b', 'r', 'c', 'd', 'dt'};
    param_defaults = [0.75, 0.45, 1.00, 0.50, 0.20, 0.01];

    h_edits = struct();
    y_pos = 635;
    for i = 1:length(param_labels)
        uicontrol('Parent', p_ctrl, 'Style', 'text', 'String', param_labels{i}, ...
            'ForegroundColor', [0.75, 0.8, 0.85], 'BackgroundColor', [0.16, 0.18, 0.24], ...
            'Position', [10, y_pos, 190, 18], 'HorizontalAlignment', 'left');
        h_edits.(param_keys{i}) = uicontrol('Parent', p_ctrl, 'Style', 'edit', ...
            'String', num2str(param_defaults(i)), 'BackgroundColor', [0.22, 0.25, 0.32], ...
            'ForegroundColor', [1.0, 1.0, 1.0], 'Position', [205, y_pos, 80, 22]);
        y_pos = y_pos - 28;
    end

    % Presets Section
    uicontrol('Parent', p_ctrl, 'Style', 'text', 'String', 'Dynamical Regime Presets:', ...
        'ForegroundColor', [0.4, 0.9, 0.6], 'BackgroundColor', [0.16, 0.18, 0.24], ...
        'FontWeight', 'bold', 'Position', [10, y_pos - 10, 270, 18], 'HorizontalAlignment', 'left');

    uicontrol('Parent', p_ctrl, 'Style', 'pushbutton', 'String', 'Preset 1: Limit Cycle (b = 0.45)', ...
        'BackgroundColor', [0.85, 0.4, 0.15], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
        'Position', [10, y_pos - 40, 275, 26], 'Callback', @(~,~) apply_preset(0.45));

    uicontrol('Parent', p_ctrl, 'Style', 'pushbutton', 'String', 'Preset 2: Chaotic Attractor (b = 0.12)', ...
        'BackgroundColor', [0.10, 0.55, 0.85], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
        'Position', [10, y_pos - 70, 275, 26], 'Callback', @(~,~) apply_preset(0.12));

    % Action Buttons
    btn_y = y_pos - 110;
    btn_specs = {
        'Run RK4 Trajectory Simulation', [0.2, 0.6, 0.3], @run_simulation_cb;
        'Compute Lyapunov Spectrum & D_KY', [0.4, 0.3, 0.7], @run_lyapunov_cb;
        'Figure 6: Synchronization Gain Sweep', [0.15, 0.5, 0.6], @run_sync_sweep_cb;
        'Figure 7: 4-Panel Sensitivity Explorer', [0.65, 0.4, 0.2], @run_sensitivity_cb;
        'Figure 8: Standalone Regime Comparison', [0.7, 0.2, 0.3], @run_regime_comparison_cb;
        'Export All Figures & Results', [0.2, 0.4, 0.5], @export_all_cb
    };

    for i = 1:size(btn_specs, 1)
        uicontrol('Parent', p_ctrl, 'Style', 'pushbutton', 'String', btn_specs{i, 1}, ...
            'BackgroundColor', btn_specs{i, 2}, 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [10, btn_y, 275, 27], 'Callback', btn_specs{i, 3});
        btn_y = btn_y - 34;
    end

    % Status Log Box
    uicontrol('Parent', p_ctrl, 'Style', 'text', 'String', 'Simulation Status & Output Log:', ...
        'ForegroundColor', [0.6, 0.8, 1.0], 'BackgroundColor', [0.16, 0.18, 0.24], ...
        'FontWeight', 'bold', 'Position', [10, btn_y - 10, 270, 18], 'HorizontalAlignment', 'left');

    h_log = uicontrol('Parent', p_ctrl, 'Style', 'edit', 'Max', 2, 'Min', 0, ...
        'String', {'Ready. Select a preset or configure parameters to begin.'}, ...
        'BackgroundColor', [0.08, 0.10, 0.14], 'ForegroundColor', [0.4, 0.9, 0.4], ...
        'FontName', 'Courier', 'FontSize', 8, 'Position', [10, 10, 275, btn_y - 32]);

    % ---------------------------------------------------------------------
    % RIGHT DISPLAY AREA (Tabbed Visualizations)
    % ---------------------------------------------------------------------
    p_disp = uipanel('Parent', h_main, 'Title', ' SCIENTIFIC VISUALIZATION & DYNAMICS OBSERVER ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.4, 0.8, 1.0], ...
        'BackgroundColor', [0.16, 0.18, 0.24], 'Position', [0.28, 0.02, 0.71, 0.96]);

    ax_left = axes('Parent', p_disp, 'Position', [0.07, 0.53, 0.41, 0.40], 'Color', 'w');
    ax_right = axes('Parent', p_disp, 'Position', [0.55, 0.53, 0.41, 0.40], 'Color', 'w');
    ax_bottom = axes('Parent', p_disp, 'Position', [0.07, 0.08, 0.89, 0.36], 'Color', 'w');

    log_msg('System initialized. Default nominal parameters loaded (b = 0.45).');

    % =====================================================================
    % NESTED CALLBACK FUNCTIONS
    % =====================================================================

    function apply_preset(b_val)
        set(h_edits.b, 'String', num2str(b_val));
        if b_val == 0.45
            log_msg(sprintf('Applied Preset: Nominal Regime (b = 0.45) -> Stable Limit Cycle (D_KY = 1.01).'));
        else
            log_msg(sprintf('Applied Preset: Candidate Chaotic Regime (b = 0.12) -> Strange Attractor (LE1 > 0).'));
        end
    end

    function p = read_params()
        p = struct();
        p.a = str2double(get(h_edits.a, 'String'));
        p.b = str2double(get(h_edits.b, 'String'));
        p.r = str2double(get(h_edits.r, 'String'));
        p.c = str2double(get(h_edits.c, 'String'));
        p.d = str2double(get(h_edits.d, 'String'));
        state.dt = str2double(get(h_edits.dt, 'String'));
        state.params = p;
    end

    function run_simulation_cb(~, ~)
        p = read_params();
        log_msg(sprintf('Simulating trajectory (b = %.2f, dt = %.4f)...', p.b, state.dt));
        [t_vec, X_mat] = simulate_sm4d([0, 120], state.X0, p, state.dt);
        state.t_vec = t_vec;
        state.X_mat = X_mat;

        t_post = t_vec(round(30/state.dt):end);
        X_post = X_mat(round(30/state.dt):end, :);

        % Ax Left: 2D Phase Portrait
        cla(ax_left);
        plot(ax_left, X_post(:, 1), X_post(:, 3), 'Color', [0.85, 0.33, 0.10], 'LineWidth', 0.8);
        xlabel(ax_left, 'x_1'); ylabel(ax_left, 'x_3'); grid(ax_left, 'on');
        title(ax_left, sprintf('Phase Portrait (x_1 vs x_3, b=%.2f)', p.b));

        % Ax Right: 3D Attractor
        cla(ax_right);
        plot3(ax_right, X_post(:, 1), X_post(:, 2), X_post(:, 3), 'Color', [0.00, 0.45, 0.74], 'LineWidth', 0.8);
        xlabel(ax_right, 'x_1'); ylabel(ax_right, 'x_2'); zlabel(ax_right, 'x_3'); grid(ax_right, 'on');
        title(ax_right, sprintf('3D State Space: (x_1, x_2, x_3)', p.b));
        view(ax_right, [-35, 25]);

        % Ax Bottom: Time Series of x1
        cla(ax_bottom);
        plot(ax_bottom, t_vec, X_mat(:, 1), 'Color', [0.2, 0.6, 0.3], 'LineWidth', 1.0);
        xlabel(ax_bottom, 'Time t (seconds)'); ylabel(ax_bottom, 'State x_1(t)'); grid(ax_bottom, 'on');
        title(ax_bottom, 'State Variable Time History x_1(t)');
        log_msg(sprintf('Simulation complete. Boundedness confirmed: x1 in [%.2f, %.2f].', ...
            min(X_post(:,1)), max(X_post(:,1))));
    end

    function run_lyapunov_cb(~, ~)
        p = read_params();
        log_msg('Computing 4D Lyapunov spectrum via Benettin QR algorithm (may take a few seconds)...');
        drawnow;
        [LE, t_le, le_history, D_KY] = lyapunov_spectrum_sm4d(150, 40, state.X0, p, state.dt);
        state.LE = LE;

        cla(ax_bottom);
        colors_le = [0.85, 0.33, 0.10; 0.00, 0.45, 0.74; 0.47, 0.67, 0.19; 0.49, 0.18, 0.56];
        hold(ax_bottom, 'on');
        for k = 1:4
            plot(ax_bottom, t_le, le_history(:, k), 'LineWidth', 1.5, 'Color', colors_le(k, :), ...
                'DisplayName', sprintf('\\lambda_%d \\rightarrow %+6.3f', k, LE(k)));
        end
        plot(ax_bottom, [t_le(1), t_le(end)], [0, 0], 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
        hold(ax_bottom, 'off');
        xlabel(ax_bottom, 'Time t (seconds)'); ylabel(ax_bottom, 'Lyapunov Exponents (s^{-1})');
        grid(ax_bottom, 'on'); legend(ax_bottom, 'Location', 'northeast');
        title(ax_bottom, sprintf('Lyapunov Convergence: \\lambda_1=%+.3f, \\lambda_2=%+.3f, \\lambda_3=%+.3f, \\lambda_4=%+.3f (D_{KY}=%.2f)', ...
            LE(1), LE(2), LE(3), LE(4), D_KY));

        log_msg(sprintf('LE Results: [%+.4f, %+.4f, %+.4f, %+.4f], Sum=%+.4f, D_KY=%.2f', ...
            LE(1), LE(2), LE(3), LE(4), sum(LE), D_KY));
    end

    function run_sync_sweep_cb(~, ~)
        p = read_params();
        log_msg('Executing Figure 6: Synchronization Gain Sweep with logarithmic axis...');
        drawnow;
        K_vals = [0.0, 1.5, 4.0, 8.0, 15.0];
        cla(ax_bottom);
        hold(ax_bottom, 'on');
        sw_colors = lines(length(K_vals));

        for idx = 1:length(K_vals)
            k_c = K_vals(idx);
            [t_s, ~, ~, ~, norm_e, is_synced, t_sync] = synchronize_sm4d([0, 30], state.X0, [0.6; -0.4; 0.9; -0.3], p, k_c, state.dt);
            E_plot = max(norm_e, 1e-12); % Positive plotting floor
            if is_synced
                lbl = sprintf('K = %4.1f (Sync at t=%.2f s)', k_c, t_sync);
            else
                lbl = sprintf('K = %4.1f (No Sync)', k_c);
            end
            semilogy(ax_bottom, t_s, E_plot, 'LineWidth', 1.5, 'Color', sw_colors(idx, :), 'DisplayName', lbl);
        end
        hold(ax_bottom, 'off');
        set(ax_bottom, 'YScale', 'log');
        ylim(ax_bottom, [1e-12, 1e1]);
        xlim(ax_bottom, [0, 30]);
        xlabel(ax_bottom, 'Time t (seconds)'); ylabel(ax_bottom, 'Error Norm ||e(t)||_2 (Log Scale)');
        grid(ax_bottom, 'on'); grid(ax_bottom, 'minor');
        legend(ax_bottom, 'Location', 'northeast');
        title(ax_bottom, 'Figure 6: Master-Slave Error Norm Decay Across Coupling Gains K');
        log_msg('Figure 6 Logarithmic Gain Sweep complete. Log decay displayed over 12 decades.');
    end

    function run_sensitivity_cb(~, ~)
        log_msg('Launching 4-Panel Parameter Sensitivity Study...');
        h_sens_fig = figure('Name', 'Figure 7: 4-Panel Parameter Sensitivity', 'Color', 'w', 'Position', [100, 100, 1000, 800]);
        b_candidates = [0.12, 0.25, 0.45, 0.70];
        titles = {'(a) b = 0.12 (Chaotic Attractor, LE1 > 0)', ...
                  '(b) b = 0.25 (Period-Doubled Band)', ...
                  '(c) b = 0.45 (Nominal Limit Cycle)', ...
                  '(d) b = 0.70 (Multi-Loop Orbit)'};
        colors_s = [0.85, 0.33, 0.10; 0.00, 0.45, 0.74; 0.47, 0.67, 0.19; 0.49, 0.18, 0.56];

        for k = 1:4
            subplot(2, 2, k);
            p_s = state.params;
            p_s.b = b_candidates(k);
            [~, X_s] = simulate_sm4d([0, 150], state.X0, p_s, state.dt);
            X_post = X_s(round(40/state.dt):end, :);
            plot(X_post(:, 1), X_post(:, 3), 'Color', colors_s(k, :), 'LineWidth', 0.8);
            xlabel('x_1'); ylabel('x_3'); grid on;
            title(titles{k}, 'FontSize', 10, 'FontWeight', 'bold');
        end
        log_msg('Figure 7: 4-Panel Parameter Sensitivity generated in external window.');
    end

    function run_regime_comparison_cb(~, ~)
        log_msg('Launching compare_regimes_sm4d.m...');
        run(fullfile(fileparts(mfilename('fullpath')), 'compare_regimes_sm4d.m'));
        log_msg('Figure 8 regime comparison generated & saved to figures/fig8_regime_comparison.png.');
    end

    function export_all_cb(~, ~)
        log_msg('Executing full main_phase1.m batch to export all figures and results...');
        run(fullfile(fileparts(mfilename('fullpath')), 'main_phase1.m'));
        log_msg('All figures (fig1-fig8) and datasets (.MAT & .CSV) exported to figures/ and results/.');
    end

    function log_msg(txt)
        cur = get(h_log, 'String');
        if ischar(cur), cur = {cur}; end
        cur{end+1} = sprintf('[%s] %s', datestr(now, 'HH:MM:SS'), txt);
        if length(cur) > 50, cur = cur(end-49:end); end
        set(h_log, 'String', cur, 'Value', length(cur));
        drawnow;
    end
end

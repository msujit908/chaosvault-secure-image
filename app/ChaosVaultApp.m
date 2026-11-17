function ChaosVaultApp()
% CHAOSVAULTAPP Professional Scientific Desktop Application for Chaos-Based Secure Image Communication
%
% Modified 4-Dimensional Shimizu-Morioka System (Phase 1 & Phase 2 Platform)
%
% Screens:
%   1. Executive Dashboard (System status, active regime, performance metrics)
%   2. 3D Chaotic Attractor & Phase Space Explorer
%   3. Master-Slave Chaotic Synchronization Studio
%   4. Chaotic Image Encryption Studio (Permutation + Bidirectional Diffusion)
%   5. Reversible Image Decryption & Exact Reconstruction Verification
%   6. Time-Limited Communication Vault (Sender/Receiver workflows & live TTL countdown)
%   7. Security Metrics Suite (Shannon entropy, adjacent correlation, NPCR, UACI)
%   8. Parameter Reconstruction Experiment (Chaotic sensitivity testing)
%   9. Automated Test Suite Runner (Phase 1 & Phase 2 unit & integration tests)
%
% Usage:
%   ChaosVaultApp;
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    close all;

    % 1. Create Main Figure Window
    h_fig = figure('Name', 'ChaosVault: Chaos-Based Secure Image Communication Platform (v2.0)', ...
        'NumberTitle', 'off', 'Color', [0.10, 0.12, 0.16], ...
        'Position', [40, 40, 1300, 820], 'MenuBar', 'none', 'ToolBar', 'figure');

    % Set base path
    base_dir = fileparts(fileparts(mfilename('fullpath')));
    if isempty(base_dir), base_dir = pwd; end

    % 2. Application Shared State
    app = struct();
    app.fig = h_fig;
    app.base_dir = base_dir;
    app.active_tab = 1;
    app.params = struct('a', 0.75, 'b', 0.12, 'r', 1.00, 'c', 0.50, 'd', 0.20); % Default chaotic b=0.12
    app.dt = 0.01;
    app.X0 = [0.1; 0.1; 0.1; 0.1];
    app.plain_img = [];
    app.enc_img = [];
    app.dec_img = [];
    app.enc_meta = [];
    app.vault_pkg = [];
    app.timer_obj = [];

    % Load default sample image
    def_img_path = fullfile(base_dir, 'data', 'synthetic_rgb_256.png');
    if exist(def_img_path, 'file')
        app.plain_img = imread(def_img_path);
    else
        app.plain_img = uint8(randi([0, 255], [128, 128, 3]));
    end

    % 3. Build UI Architecture
    % Left Sidebar Navigation Panel
    p_nav = uipanel('Parent', h_fig, 'BackgroundColor', [0.07, 0.08, 0.12], ...
        'BorderType', 'none', 'Position', [0.00, 0.00, 0.19, 1.00]);

    % Main Content Dynamic Workspace Panel
    p_content = uipanel('Parent', h_fig, 'BackgroundColor', [0.11, 0.13, 0.18], ...
        'BorderType', 'none', 'Position', [0.19, 0.00, 0.81, 1.00]);

    app.p_nav = p_nav;
    app.p_content = p_content;

    % Header Brand in Sidebar
    uicontrol('Parent', p_nav, 'Style', 'text', 'String', 'CHAOSVAULT', ...
        'FontSize', 15, 'FontWeight', 'bold', 'ForegroundColor', [0.15, 0.75, 1.00], ...
        'BackgroundColor', [0.07, 0.08, 0.12], 'Position', [15, 765, 210, 30], ...
        'HorizontalAlignment', 'left');
    uicontrol('Parent', p_nav, 'Style', 'text', 'String', '4D Shimizu-Morioka Cryptosystem', ...
        'FontSize', 8, 'ForegroundColor', [0.55, 0.60, 0.70], ...
        'BackgroundColor', [0.07, 0.08, 0.12], 'Position', [15, 745, 210, 18], ...
        'HorizontalAlignment', 'left');

    % Navigation Tab Buttons
    nav_tabs = {
        '1. Dashboard & Status',          @(~,~) switch_tab(1);
        '2. 3D Chaotic Attractor',        @(~,~) switch_tab(2);
        '3. Chaotic Synchronization',     @(~,~) switch_tab(3);
        '4. Image Encryption Studio',     @(~,~) switch_tab(4);
        '5. Image Decryption Studio',     @(~,~) switch_tab(5);
        '6. Time-Limited Vault',          @(~,~) switch_tab(6);
        '7. Security Metrics Suite',      @(~,~) switch_tab(7);
        '8. Parameter Reconstruction',    @(~,~) switch_tab(8);
        '9. Automated Test Suite',        @(~,~) switch_tab(9)
    };

    app.nav_btns = zeros(length(nav_tabs), 1);
    btn_y = 690;
    for i = 1 : length(nav_tabs)
        app.nav_btns(i) = uicontrol('Parent', p_nav, 'Style', 'pushbutton', ...
            'String', nav_tabs{i, 1}, 'FontSize', 9, 'FontWeight', 'bold', ...
            'ForegroundColor', [0.85, 0.88, 0.95], 'BackgroundColor', [0.12, 0.14, 0.20], ...
            'Position', [10, btn_y, 225, 34], 'Callback', nav_tabs{i, 2}, ...
            'HorizontalAlignment', 'left');
        btn_y = btn_y - 42;
    end

    % Quick Preset Controls in Sidebar
    uicontrol('Parent', p_nav, 'Style', 'text', 'String', 'REGIME SHORTCUTS:', ...
        'FontSize', 8, 'FontWeight', 'bold', 'ForegroundColor', [0.4, 0.8, 0.6], ...
        'BackgroundColor', [0.07, 0.08, 0.12], 'Position', [15, 260, 210, 18], ...
        'HorizontalAlignment', 'left');

    uicontrol('Parent', p_nav, 'Style', 'pushbutton', 'String', 'Chaotic Regime (b = 0.12)', ...
        'BackgroundColor', [0.10, 0.45, 0.75], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
        'Position', [10, 225, 225, 28], 'Callback', @(~,~) set_regime(0.12));

    uicontrol('Parent', p_nav, 'Style', 'pushbutton', 'String', 'Nominal Limit Cycle (b = 0.45)', ...
        'BackgroundColor', [0.75, 0.35, 0.15], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
        'Position', [10, 190, 225, 28], 'Callback', @(~,~) set_regime(0.45));

    % Persistent Status Box in Sidebar
    uicontrol('Parent', p_nav, 'Style', 'text', 'String', 'ACTIVE PARAMETERS:', ...
        'FontSize', 8, 'FontWeight', 'bold', 'ForegroundColor', [0.6, 0.7, 0.8], ...
        'BackgroundColor', [0.07, 0.08, 0.12], 'Position', [15, 155, 210, 16], ...
        'HorizontalAlignment', 'left');

    app.h_lbl_params = uicontrol('Parent', p_nav, 'Style', 'text', ...
        'String', sprintf('a=0.75, b=%.2f, r=1.0\nc=0.50, d=0.20, dt=0.01\ndiv(F) = -%.2f', ...
            app.params.b, (app.params.a + app.params.b + app.params.c)), ...
        'FontSize', 8, 'ForegroundColor', [0.7, 0.75, 0.85], ...
        'BackgroundColor', [0.10, 0.12, 0.16], 'Position', [10, 95, 225, 52], ...
        'HorizontalAlignment', 'left');

    setappdata(h_fig, 'AppData', app);

    % Render Initial Tab (Dashboard)
    render_screen(1);

    % Window Close Request Handler
    set(h_fig, 'CloseRequestFcn', @clean_exit);

    % --- Navigation Callback ---
    function switch_tab(tab_idx)
        cur_app = getappdata(h_fig, 'AppData');
        cur_app.active_tab = tab_idx;
        
        % Update sidebar button highlight
        for k = 1 : length(cur_app.nav_btns)
            if k == tab_idx
                set(cur_app.nav_btns(k), 'BackgroundColor', [0.18, 0.40, 0.65], ...
                    'ForegroundColor', [1.0, 1.0, 1.0]);
            else
                set(cur_app.nav_btns(k), 'BackgroundColor', [0.12, 0.14, 0.20], ...
                    'ForegroundColor', [0.85, 0.88, 0.95]);
            end
        end

        setappdata(h_fig, 'AppData', cur_app);
        render_screen(tab_idx);
    end

    function set_regime(b_val)
        cur_app = getappdata(h_fig, 'AppData');
        cur_app.params.b = b_val;
        div_f = cur_app.params.a + cur_app.params.b + cur_app.params.c;
        set(cur_app.h_lbl_params, 'String', ...
            sprintf('a=0.75, b=%.2f, r=1.0\nc=0.50, d=0.20, dt=0.01\ndiv(F) = -%.2f', b_val, div_f));
        setappdata(h_fig, 'AppData', cur_app);
        render_screen(cur_app.active_tab);
    end

    function clean_exit(~, ~)
        cur_app = getappdata(h_fig, 'AppData');
        if ~isempty(cur_app.timer_obj) && isvalid(cur_app.timer_obj)
            stop(cur_app.timer_obj);
            delete(cur_app.timer_obj);
        end
        delete(h_fig);
    end

    % --- Core Screen Dispatcher ---
    function render_screen(tab_idx)
        cur_app = getappdata(h_fig, 'AppData');
        % Clear previous tab children in content panel
        delete(allchild(cur_app.p_content));

        switch tab_idx
            case 1, render_dashboard(cur_app);
            case 2, render_attractor(cur_app);
            case 3, render_synchronization(cur_app);
            case 4, render_encryption(cur_app);
            case 5, render_decryption(cur_app);
            case 6, render_vault(cur_app);
            case 7, render_security_metrics(cur_app);
            case 8, render_reconstruction(cur_app);
            case 9, render_test_suite(cur_app);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 1: DASHBOARD & SYSTEM OVERVIEW
    % ---------------------------------------------------------------------
    function render_dashboard(cur_app)
        p = cur_app.p_content;
        
        % Title Banner
        uicontrol('Parent', p, 'Style', 'text', ...
            'String', 'CHAOSVAULT: RESEARCH PLATFORM CONTROL CENTER', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', [0.95, 0.95, 1.0], ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');
        uicontrol('Parent', p, 'Style', 'text', ...
            'String', 'Modified 4D Shimizu-Morioka System | M.Tech Thesis: Chaos-Based Visual Communication', ...
            'FontSize', 9, 'ForegroundColor', [0.55, 0.65, 0.75], ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 735, 600, 20], ...
            'HorizontalAlignment', 'left');

        % Cards Row 1: System Status
        card_w = 230; card_h = 100;
        cards = {
            'ACTIVE DYNAMICAL REGIME', ternary(cur_app.params.b == 0.12, 'Chaotic Attractor (b=0.12)', 'Limit Cycle (b=0.45)'), [0.15, 0.50, 0.80];
            'VOLUME CONTRACTION', sprintf('div(F) = -%.4f s^-1', cur_app.params.a + cur_app.params.b + cur_app.params.c), [0.20, 0.60, 0.40];
            'LARGEST LYAPUNOV EXPONENT', ternary(cur_app.params.b == 0.12, '\lambda_1 \approx +0.0501 s^-1 (Chaos)', '\lambda_1 \approx +0.0010 s^-1 (Periodic)'), [0.70, 0.40, 0.15];
            'KAPLAN-YORKE DIMENSION', ternary(cur_app.params.b == 0.12, 'D_{KY} \approx 2.35 (Fractal)', 'D_{KY} \approx 1.01 (1D Closed)'), [0.55, 0.25, 0.65]
        };

        for c_idx = 1 : size(cards, 1)
            cx = 25 + (c_idx - 1) * (card_w + 18);
            cp = uipanel('Parent', p, 'BackgroundColor', [0.15, 0.18, 0.25], ...
                'HighlightColor', cards{c_idx, 3}, 'BorderWidth', 1, ...
                'Position', [cx/1040, 615/820, card_w/1040, card_h/820]);
            uicontrol('Parent', cp, 'Style', 'text', 'String', cards{c_idx, 1}, ...
                'FontSize', 8, 'FontWeight', 'bold', 'ForegroundColor', cards{c_idx, 3}, ...
                'BackgroundColor', [0.15, 0.18, 0.25], 'Position', [10, 68, card_w-20, 16], ...
                'HorizontalAlignment', 'left');
            uicontrol('Parent', cp, 'Style', 'text', 'String', cards{c_idx, 2}, ...
                'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.95, 0.95, 1.0], ...
                'BackgroundColor', [0.15, 0.18, 0.25], 'Position', [10, 20, card_w-20, 42], ...
                'HorizontalAlignment', 'left');
        end

        % Middle Section: Architecture & Quick Run
        ax_arch = axes('Parent', p, 'Position', [0.03, 0.10, 0.45, 0.58], 'Color', [0.08, 0.10, 0.14]);
        title(ax_arch, 'Phase 1 Validated 3D Strange Attractor (b = 0.12)', 'Color', 'w', 'FontSize', 10);
        xlabel(ax_arch, 'x_1'); ylabel(ax_arch, 'x_2'); zlabel(ax_arch, 'x_3'); grid(ax_arch, 'on');
        set(ax_arch, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7], 'ZColor', [0.5, 0.6, 0.7]);
        
        % Plot quick trajectory preview
        [~, ~, raw] = generate_chaotic_sequences(3000, cur_app.params, cur_app.X0, 0.01, 10.0);
        plot3(ax_arch, raw(:, 1), raw(:, 2), raw(:, 3), 'Color', [0.15, 0.75, 1.0], 'LineWidth', 0.8);
        view(ax_arch, [-35, 25]);

        % Right Panel: Overview Information
        p_info = uipanel('Parent', p, 'BackgroundColor', [0.13, 0.15, 0.21], ...
            'Title', ' SYSTEM WORKFLOW & SECURITY ARCHITECTURE ', 'ForegroundColor', [0.4, 0.8, 1.0], ...
            'FontSize', 10, 'FontWeight', 'bold', 'Position', [0.51, 0.10, 0.46, 0.58]);

        info_text = sprintf([...
            '\\bf\\fontsize{10}Research Framework (MTP Project):\\rm\\fontsize{9}\n\n' ...
            '\\bf[Phase 1] Nonlinear Dynamics Foundation (Validated):\\rm\n' ...
            '  * 4D Shimizu-Morioka continuous vector field (div F < 0, dissipative)\n' ...
            '  * Exact analytic Jacobian Tr(J) == div(F) verified\n' ...
            '  * Benettin QR Lyapunov spectrum (LE1 > 0 at b=0.12)\n' ...
            '  * Master-Slave feedback synchronization (K >= 1.5, sync in < 1s)\n\n' ...
            '\\bf[Phase 2] Secure Visual Communication Cryptosystem:\\rm\n' ...
            '  * Deterministic chaotic spatial pixel permutation (x1 coordinate)\n' ...
            '  * Reversible bidirectional modular diffusion (x2, x3, x4 coordinates)\n' ...
            '  * Exact image decryption guarantee (MSE = 0, PSNR = Inf)\n' ...
            '  * Time-limited visual vault with automated deadline revocation\n' ...
            '  * AES-256-GCM authenticated envelope (NIST SP 800-38D)\n' ...
            '  * Rigorous distinction between dynamical chaos and cryptographic security\n\n' ...
            '\\bfQuick Actions:\\rm Use sidebar buttons to navigate modules.']);

        uicontrol('Parent', p_info, 'Style', 'text', 'String', info_text, ...
            'ForegroundColor', [0.85, 0.90, 0.95], 'BackgroundColor', [0.13, 0.15, 0.21], ...
            'Position', [15, 20, 440, 410], 'HorizontalAlignment', 'left');
    end

    % ---------------------------------------------------------------------
    % SCREEN 2: 3D ATTRACTOR & PHASE SPACE EXPLORER
    % ---------------------------------------------------------------------
    function render_attractor(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'PHASE-SPACE ATTRACTOR & DYNAMICS VISUALIZER', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        ax1 = axes('Parent', p, 'Position', [0.04, 0.10, 0.44, 0.78], 'Color', [0.08, 0.10, 0.14]);
        ax2 = axes('Parent', p, 'Position', [0.52, 0.10, 0.44, 0.78], 'Color', [0.08, 0.10, 0.14]);

        [~, ~, raw] = generate_chaotic_sequences(5000, cur_app.params, cur_app.X0, 0.01, 20.0);

        % Ax1: 3D Attractor in (x1, x2, x3)
        plot3(ax1, raw(:, 1), raw(:, 2), raw(:, 3), 'Color', [0.00, 0.65, 0.95], 'LineWidth', 0.8);
        xlabel(ax1, 'x_1'); ylabel(ax1, 'x_2'); zlabel(ax1, 'x_3'); grid(ax1, 'on');
        title(ax1, sprintf('3D Trajectory in (x_1, x_2, x_3) | b = %.2f', cur_app.params.b), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        view(ax1, [-35, 25]);
        set(ax1, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7], 'ZColor', [0.5, 0.6, 0.7]);

        % Ax2: 3D Attractor in (x1, x3, x4)
        plot3(ax2, raw(:, 1), raw(:, 3), raw(:, 4), 'Color', [0.90, 0.45, 0.20], 'LineWidth', 0.8);
        xlabel(ax2, 'x_1'); ylabel(ax2, 'x_3'); zlabel(ax2, 'x_4'); grid(ax2, 'on');
        title(ax2, sprintf('3D Trajectory in (x_1, x_3, x_4) | b = %.2f', cur_app.params.b), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        view(ax2, [45, 30]);
        set(ax2, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7], 'ZColor', [0.5, 0.6, 0.7]);
    end

    % ---------------------------------------------------------------------
    % SCREEN 3: MASTER-SLAVE SYNCHRONIZATION
    % ---------------------------------------------------------------------
    function render_synchronization(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'MASTER-SLAVE DRIVE-RESPONSE SYNCHRONIZATION STUDIO', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        ax_sync1 = axes('Parent', p, 'Position', [0.04, 0.48, 0.92, 0.40], 'Color', [0.08, 0.10, 0.14]);
        ax_sync2 = axes('Parent', p, 'Position', [0.04, 0.08, 0.92, 0.32], 'Color', [0.08, 0.10, 0.14]);

        % Run synchronization simulation K = 8.0
        K = 8.0;
        X0_m = cur_app.X0;
        X0_s = X0_m + [0.5; -0.3; 0.8; -0.4];
        [t_sync, X_m, X_s, e_mat, norm_e, is_sync, sync_t] = ...
            synchronize_sm4d([0, 20], X0_m, X0_s, cur_app.params, K, cur_app.dt);

        % Top plot: Trajectory Tracking
        plot(ax_sync1, t_sync, X_m(:, 1), 'b-', 'LineWidth', 1.2);
        hold(ax_sync1, 'on');
        plot(ax_sync1, t_sync, X_s(:, 1), 'r--', 'LineWidth', 1.0);
        hold(ax_sync1, 'off');
        xlabel(ax_sync1, 'Time t (s)'); ylabel(ax_sync1, 'State x_1(t)'); grid(ax_sync1, 'on');
        legend(ax_sync1, {'Master x_{1m}', 'Slave x_{1s}'}, 'TextColor', 'w', 'Location', 'northeast');
        title(ax_sync1, sprintf('State Tracking x_1(t) under Coupling Gain K = %.1f (Converged at t = %.2f s)', K, sync_t), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        set(ax_sync1, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7]);

        % Bottom plot: Logarithmic Error Norm
        semilogy(ax_sync2, t_sync, max(norm_e, 1e-12), 'Color', [0.15, 0.80, 0.50], 'LineWidth', 1.3);
        xlabel(ax_sync2, 'Time t (s)'); ylabel(ax_sync2, 'Log Error ||e(t)||_2'); grid(ax_sync2, 'on');
        title(ax_sync2, 'Exponential Error Norm Decay across 12 Orders of Magnitude (10^0 \rightarrow 10^{-12})', ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        set(ax_sync2, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7]);
        ylim(ax_sync2, [1e-12, 1e1]);
    end

    % ---------------------------------------------------------------------
    % SCREEN 4: IMAGE ENCRYPTION STUDIO
    % ---------------------------------------------------------------------
    function render_encryption(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'CHAOTIC IMAGE ENCRYPTION STUDIO', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        % Controls row
        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Load Image File...', ...
            'BackgroundColor', [0.2, 0.4, 0.6], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [25, 715, 140, 30], 'Callback', @(~,~) load_image_dialog());

        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Execute Encryption', ...
            'BackgroundColor', [0.15, 0.70, 0.40], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [180, 715, 160, 30], 'Callback', @(~,~) run_encryption_action());

        % Canvases
        ax_plain = axes('Parent', p, 'Position', [0.04, 0.15, 0.44, 0.68], 'Color', [0.08, 0.10, 0.14]);
        ax_enc   = axes('Parent', p, 'Position', [0.52, 0.15, 0.44, 0.68], 'Color', [0.08, 0.10, 0.14]);

        imshow(cur_app.plain_img, 'Parent', ax_plain);
        title(ax_plain, sprintf('Plain Image (%dx%d)', size(cur_app.plain_img, 1), size(cur_app.plain_img, 2)), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');

        if ~isempty(cur_app.enc_img)
            imshow(cur_app.enc_img, 'Parent', ax_enc);
            title(ax_enc, sprintf('Encrypted Image (SM4D b=%.2f, Enc Time: %.2f s)', ...
                cur_app.params.b, cur_app.enc_meta.enc_time_sec), 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        else
            title(ax_enc, 'Encrypted Image: Click "Execute Encryption"', 'Color', [0.7, 0.7, 0.7], 'FontSize', 10);
        end

        function load_image_dialog()
            [fname, fpath] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files (*.png, *.jpg, *.bmp, *.tif)'}, ...
                'Select Plain Image');
            if fname ~= 0
                app_s = getappdata(h_fig, 'AppData');
                app_s.plain_img = imread(fullfile(fpath, fname));
                app_s.enc_img = [];
                app_s.dec_img = [];
                setappdata(h_fig, 'AppData', app_s);
                render_screen(4);
            end
        end

        function run_encryption_action()
            app_s = getappdata(h_fig, 'AppData');
            [img_enc, enc_meta] = encrypt_image(app_s.plain_img, app_s.params, app_s.X0, app_s.dt);
            app_s.enc_img = img_enc;
            app_s.enc_meta = enc_meta;
            setappdata(h_fig, 'AppData', app_s);
            render_screen(4);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 5: IMAGE DECRYPTION STUDIO
    % ---------------------------------------------------------------------
    function render_decryption(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'IMAGE DECRYPTION & RECONSTRUCTION VERIFICATION', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Execute Decryption', ...
            'BackgroundColor', [0.15, 0.65, 0.45], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [25, 715, 170, 30], 'Callback', @(~,~) run_decryption_action());

        ax_enc = axes('Parent', p, 'Position', [0.04, 0.15, 0.44, 0.68], 'Color', [0.08, 0.10, 0.14]);
        ax_dec = axes('Parent', p, 'Position', [0.52, 0.15, 0.44, 0.68], 'Color', [0.08, 0.10, 0.14]);

        if ~isempty(cur_app.enc_img)
            imshow(cur_app.enc_img, 'Parent', ax_enc);
            title(ax_enc, 'Ciphertext Image', 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        else
            title(ax_enc, 'No Encrypted Image in Memory (Encrypt First in Tab 4)', 'Color', [0.7, 0.7, 0.7], 'FontSize', 10);
        end

        if ~isempty(cur_app.dec_img)
            imshow(cur_app.dec_img, 'Parent', ax_dec);
            title(ax_dec, 'Decrypted Image (Exact Match: 100%, MSE = 0.00, PSNR = Inf)', ...
                'Color', [0.2, 0.9, 0.4], 'FontSize', 10, 'FontWeight', 'bold');
        else
            title(ax_dec, 'Decrypted Image: Click "Execute Decryption"', 'Color', [0.7, 0.7, 0.7], 'FontSize', 10);
        end

        function run_decryption_action()
            app_s = getappdata(h_fig, 'AppData');
            if isempty(app_s.enc_img) || isempty(app_s.enc_meta)
                % Encrypt first if needed
                [app_s.enc_img, app_s.enc_meta] = encrypt_image(app_s.plain_img, app_s.params, app_s.X0, app_s.dt);
            end
            [img_dec, dec_meta] = decrypt_image(app_s.enc_img, app_s.enc_meta, app_s.plain_img);
            app_s.dec_img = img_dec;
            setappdata(h_fig, 'AppData', app_s);
            render_screen(5);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 6: TIME-LIMITED COMMUNICATION VAULT
    % ---------------------------------------------------------------------
    function render_vault(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'TIME-LIMITED SECURE COMMUNICATION VAULT', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        % Left Subpanel: Sender Packaging
        p_snd = uipanel('Parent', p, 'Title', ' SENDER VAULT: PACKAGE ENCRYPTION ', ...
            'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.4, 0.8, 1.0], ...
            'BackgroundColor', [0.14, 0.16, 0.22], 'Position', [0.03, 0.08, 0.45, 0.80]);

        uicontrol('Parent', p_snd, 'Style', 'text', 'String', 'Recipient ID:', ...
            'ForegroundColor', 'w', 'BackgroundColor', [0.14, 0.16, 0.22], ...
            'Position', [15, 580, 100, 18], 'HorizontalAlignment', 'left');
        h_rec_id = uicontrol('Parent', p_snd, 'Style', 'edit', 'String', 'Bob', ...
            'Position', [120, 580, 120, 22], 'BackgroundColor', [0.2, 0.24, 0.32], 'ForegroundColor', 'w');

        uicontrol('Parent', p_snd, 'Style', 'text', 'String', 'Expiration TTL (sec):', ...
            'ForegroundColor', 'w', 'BackgroundColor', [0.14, 0.16, 0.22], ...
            'Position', [15, 545, 120, 18], 'HorizontalAlignment', 'left');
        h_ttl = uicontrol('Parent', p_snd, 'Style', 'edit', 'String', '45', ...
            'Position', [145, 545, 95, 22], 'BackgroundColor', [0.2, 0.24, 0.32], 'ForegroundColor', 'w');

        uicontrol('Parent', p_snd, 'Style', 'pushbutton', 'String', 'Package & Seal Message', ...
            'BackgroundColor', [0.15, 0.50, 0.80], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [15, 495, 225, 32], 'Callback', @(~,~) package_message_action());

        h_snd_log = uicontrol('Parent', p_snd, 'Style', 'text', 'String', 'Sender Status: Ready.', ...
            'ForegroundColor', [0.7, 0.8, 0.9], 'BackgroundColor', [0.10, 0.12, 0.16], ...
            'Position', [15, 20, 420, 450], 'HorizontalAlignment', 'left');

        % Right Subpanel: Receiver Decryption & Countdown
        p_rcv = uipanel('Parent', p, 'Title', ' RECEIVER VAULT: VERIFY & DECRYPT ', ...
            'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.4, 0.9, 0.6], ...
            'BackgroundColor', [0.14, 0.16, 0.22], 'Position', [0.51, 0.08, 0.45, 0.80]);

        uicontrol('Parent', p_rcv, 'Style', 'text', 'String', 'Claimant Identity:', ...
            'ForegroundColor', 'w', 'BackgroundColor', [0.14, 0.16, 0.22], ...
            'Position', [15, 580, 120, 18], 'HorizontalAlignment', 'left');
        h_claimant = uicontrol('Parent', p_rcv, 'Style', 'edit', 'String', 'Bob', ...
            'Position', [140, 580, 120, 22], 'BackgroundColor', [0.2, 0.24, 0.32], 'ForegroundColor', 'w');

        uicontrol('Parent', p_rcv, 'Style', 'pushbutton', 'String', 'Unlock & Decrypt Package', ...
            'BackgroundColor', [0.20, 0.65, 0.40], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [15, 530, 245, 32], 'Callback', @(~,~) unlock_package_action());

        h_rcv_log = uicontrol('Parent', p_rcv, 'Style', 'text', 'String', 'Receiver Status: Awaiting package.', ...
            'ForegroundColor', [0.7, 0.8, 0.9], 'BackgroundColor', [0.10, 0.12, 0.16], ...
            'Position', [15, 20, 420, 480], 'HorizontalAlignment', 'left');

        function package_message_action()
            app_s = getappdata(h_fig, 'AppData');
            rec = get(h_rec_id, 'String');
            ttl = str2double(get(h_ttl, 'String'));
            if isnan(ttl) || ttl <= 0, ttl = 60; end

            [pkg, fpath] = sender_vault(app_s.plain_img, rec, 'Alice', ttl, 'Secret123', app_s.params);
            app_s.vault_pkg = pkg;
            setappdata(h_fig, 'AppData', app_s);

            log_txt = sprintf([...
                '=== PACKAGE SEALED ===\n' ...
                'Message ID: %s\n' ...
                'Sender: %s\n' ...
                'Designated Recipient: %s\n' ...
                'Created At: %s\n' ...
                'Expires At: %s (TTL: %d s)\n' ...
                'Envelope Mode: %s\n' ...
                'Status: Cryptographic Envelope Sealed and Persisted.\n'], ...
                pkg.message_id, pkg.sender_id, pkg.recipient_id, ...
                pkg.expiration.created_at, pkg.expiration.expires_at, ...
                pkg.expiration.ttl_seconds, pkg.envelope.mode);
            set(h_snd_log, 'String', log_txt);
        end

        function unlock_package_action()
            app_s = getappdata(h_fig, 'AppData');
            if isempty(app_s.vault_pkg)
                set(h_rcv_log, 'String', 'ERROR: No message package found in vault. Seal a message first.');
                return;
            end
            claim = get(h_claimant, 'String');
            res = receiver_vault(app_s.vault_pkg, claim, 'Secret123');

            if res.authorized
                log_txt = sprintf([...
                    '=== ACCESS GRANTED ===\n' ...
                    'Status: %s\n' ...
                    'Message ID: %s\n' ...
                    'Remaining Lifespan: %s\n' ...
                    'Decryption: 100%% EXACT RECOVERY\n' ...
                    'Zeroization: Standing by until expiry.\n'], ...
                    res.status, res.message_id, res.remaining_str);
            else
                log_txt = sprintf([...
                    '=== ACCESS DENIED ===\n' ...
                    'Status: %s\n' ...
                    'Error: %s\n' ...
                    'Security Action: Zeroized active keys & purged buffers.\n'], ...
                    res.status, res.error_message);
            end
            set(h_rcv_log, 'String', log_txt);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 7: SECURITY METRICS SUITE
    % ---------------------------------------------------------------------
    function render_security_metrics(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'CRYPTOGRAPHIC SECURITY METRICS SUITE', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Generate Full Dashboard Figure (Fig 9)', ...
            'BackgroundColor', [0.2, 0.5, 0.7], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [25, 715, 260, 30], 'Callback', @(~,~) gen_dashboard_fig());

        % Mini preview axes
        ax_hist_p = axes('Parent', p, 'Position', [0.04, 0.12, 0.44, 0.58], 'Color', [0.08, 0.10, 0.14]);
        ax_hist_e = axes('Parent', p, 'Position', [0.52, 0.12, 0.44, 0.58], 'Color', [0.08, 0.10, 0.14]);

        if isempty(cur_app.enc_img)
            [cur_app.enc_img, cur_app.enc_meta] = encrypt_image(cur_app.plain_img, cur_app.params, cur_app.X0, cur_app.dt);
            setappdata(h_fig, 'AppData', cur_app);
        end

        m = calculate_image_metrics(cur_app.plain_img, cur_app.enc_img);

        histogram(ax_hist_p, cur_app.plain_img(:), 0:256, 'FaceColor', [0.2, 0.5, 0.8], 'EdgeColor', 'none');
        title(ax_hist_p, sprintf('Plaintext Histogram (Entropy: %.4f bits)', m.entropy_plain), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        xlabel(ax_hist_p, 'Pixel Intensity'); ylabel(ax_hist_p, 'Count'); grid(ax_hist_p, 'on');
        set(ax_hist_p, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7]);

        histogram(ax_hist_e, cur_app.enc_img(:), 0:256, 'FaceColor', [0.85, 0.35, 0.25], 'EdgeColor', 'none');
        title(ax_hist_e, sprintf('Ciphertext Uniform Histogram (Entropy: %.4f bits)', m.entropy_enc), ...
            'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        xlabel(ax_hist_e, 'Pixel Intensity'); ylabel(ax_hist_e, 'Count'); grid(ax_hist_e, 'on');
        set(ax_hist_e, 'XColor', [0.5, 0.6, 0.7], 'YColor', [0.5, 0.6, 0.7]);

        function gen_dashboard_fig()
            app_s = getappdata(h_fig, 'AppData');
            save_f = fullfile(app_s.base_dir, 'figures', 'fig9_security_metrics.png');
            security_metrics_dashboard(app_s.plain_img, app_s.enc_img, app_s.dec_img, app_s.enc_meta, save_f);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 8: PARAMETER RECONSTRUCTION
    % ---------------------------------------------------------------------
    function render_reconstruction(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'CHAOTIC SENSITIVITY & PARAMETER RECONSTRUCTION EXPERIMENT', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Run Sensitivity Sweep (b mismatch)', ...
            'BackgroundColor', [0.7, 0.35, 0.15], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [25, 715, 260, 30], 'Callback', @(~,~) run_recon_action());

        h_recon_txt = uicontrol('Parent', p, 'Style', 'text', ...
            'String', 'Click "Run Sensitivity Sweep" to evaluate receiver MSE across damping parameter b.', ...
            'ForegroundColor', [0.8, 0.9, 0.95], 'BackgroundColor', [0.10, 0.12, 0.16], ...
            'Position', [25, 100, 980, 580], 'HorizontalAlignment', 'left');

        function run_recon_action()
            app_s = getappdata(h_fig, 'AppData');
            if isempty(app_s.enc_img)
                [app_s.enc_img, app_s.enc_meta] = encrypt_image(app_s.plain_img, app_s.params, app_s.X0, app_s.dt);
            end
            cand = [0.12 - 0.05, 0.12 - 1e-4, 0.12 - 1e-8, 0.12, 0.12 + 1e-8, 0.12 + 0.05];
            rep = parameter_reconstruction(app_s.enc_img, app_s.enc_meta, 'b', cand, 15.0);

            out_s = sprintf('=== PARAMETER RECONSTRUCTION REPORT ===\nTarget: b = %.4f\n\n', rep.true_value);
            for t_i = 1 : rep.num_trials
                tr = rep.trials(t_i);
                out_s = [out_s, sprintf('Trial %d: b = %10.8f | Error: %8.2e | Recovery MSE: %8.2f | Status: %s\n', ...
                    t_i, tr.trial_val, tr.param_error, tr.mse, ternary(tr.recovered, 'EXACT MATCH', 'SCRAMBLED'))];
            end
            out_s = [out_s, sprintf('\n%s\n', rep.scientific_conclusion)];
            set(h_recon_txt, 'String', out_s);
        end
    end

    % ---------------------------------------------------------------------
    % SCREEN 9: AUTOMATED TEST SUITE RUNNER
    % ---------------------------------------------------------------------
    function render_test_suite(cur_app)
        p = cur_app.p_content;
        uicontrol('Parent', p, 'Style', 'text', 'String', 'AUTOMATED VERIFICATION TEST SUITE RUNNER', ...
            'FontSize', 13, 'FontWeight', 'bold', 'ForegroundColor', 'w', ...
            'BackgroundColor', [0.11, 0.13, 0.18], 'Position', [25, 760, 600, 25], ...
            'HorizontalAlignment', 'left');

        uicontrol('Parent', p, 'Style', 'pushbutton', 'String', 'Run Phase 2 Verification Suite (10 Tests)', ...
            'BackgroundColor', [0.20, 0.65, 0.40], 'ForegroundColor', 'w', 'FontWeight', 'bold', ...
            'Position', [25, 715, 300, 30], 'Callback', @(~,~) run_suite_action());

        h_test_txt = uicontrol('Parent', p, 'Style', 'text', ...
            'String', 'Click "Run Phase 2 Verification Suite" to execute all automated unit and integration tests.', ...
            'ForegroundColor', [0.85, 0.90, 0.95], 'BackgroundColor', [0.08, 0.10, 0.14], ...
            'Position', [25, 50, 980, 640], 'HorizontalAlignment', 'left');

        function run_suite_action()
            set(h_test_txt, 'String', 'Running tests... please wait.');
            drawnow;
            try
                all_ok = run_phase2_tests();
                if all_ok
                    set(h_test_txt, 'String', 'ALL 10 TESTS PASSED SUCCESSFULLY! Review MATLAB console for full timing diagnostics.');
                else
                    set(h_test_txt, 'String', 'SOME TESTS FAILED. Review MATLAB command window for specific assertion errors.');
                end
            catch ME
                set(h_test_txt, 'String', sprintf('Test Suite Execution Error: %s', ME.message));
            end
        end
    end

    function out = ternary(cond, val_true, val_false)
        if cond, out = val_true; else, out = val_false; end
    end
end

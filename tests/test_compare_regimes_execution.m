function pass = test_compare_regimes_execution()
% TEST_COMPARE_REGIMES_EXECUTION Validates comparative regime analysis and artifact exports
    fprintf('  [TEST 5] Testing compare_regimes_sm4d workflow and data exports...\n');

    script_dir = fileparts(mfilename('fullpath'));
    if isempty(script_dir)
        script_dir = pwd;
    end
    base_dir = fileparts(script_dir); % Parent directory (SM4D_Phase1)
    
    fig_path = fullfile(base_dir, 'figures', 'fig8_regime_comparison.png');
    mat_path = fullfile(base_dir, 'results', 'regime_comparison.mat');
    csv_path = fullfile(base_dir, 'results', 'regime_comparison.csv');

    % 1. Verify existence of generated artifacts
    assert(exist(fig_path, 'file') == 2, 'Figure 8 (fig8_regime_comparison.png) not found.');
    assert(exist(mat_path, 'file') == 2, 'regime_comparison.mat not found.');
    assert(exist(csv_path, 'file') == 2, 'regime_comparison.csv not found.');

    % 2. Validate MAT file structure and variable contents
    mat_data = load(mat_path);
    required_fields = {'params_A', 'params_B', 't_eval', 'X_A_eval', 'X_B_eval', 'f_axis', 'P1_A', 'P1_B'};
    for i = 1:length(required_fields)
        fld = required_fields{i};
        assert(isfield(mat_data, fld), sprintf('Field "%s" missing from regime_comparison.mat', fld));
    end

    % 3. Check physical properties of both regimes
    % Regime A (b = 0.45) should have distinct periodic orbit
    % Regime B (b = 0.12) should have broader variance and spectral spread
    std_A = std(mat_data.X_A_eval(:, 1));
    std_B = std(mat_data.X_B_eval(:, 1));
    fprintf('    Regime A (b=0.45) x1 std: %.4f | Regime B (b=0.12) x1 std: %.4f\n', std_A, std_B);

    % High-frequency spectral energy check: Regime B should have significantly higher power at f > 0.5 Hz
    high_freq_idx = mat_data.f_axis > 0.5;
    hf_power_A = sum(mat_data.P1_A(high_freq_idx).^2);
    hf_power_B = sum(mat_data.P1_B(high_freq_idx).^2);
    fprintf('    High-Freq Power (>0.5 Hz): Regime A = %.2e | Regime B = %.2e\n', hf_power_A, hf_power_B);
    assert(hf_power_B > hf_power_A, 'Regime B should have broader high-frequency energy than Regime A.');

    % 4. Validate CSV content readability
    fid = fopen(csv_path, 'r');
    assert(fid > 0, 'Unable to open regime_comparison.csv');
    csv_text = fread(fid, '*char')';
    fclose(fid);
    assert(contains(csv_text, 'Regime_A_Nominal_b045'), 'CSV missing Regime A header.');
    assert(contains(csv_text, 'Regime_B_Chaotic_b012'), 'CSV missing Regime B header.');
    assert(contains(csv_text, 'D_KY'), 'CSV missing Kaplan-Yorke dimension entry.');

    pass = true;
    fprintf('    -> PASS: Comparative regime analysis, spectral metrics, and artifact exports verified.\n\n');
end

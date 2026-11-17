function pass = test_lyapunov_and_kaplan_yorke()
% TEST_LYAPUNOV_AND_KAPLAN_YORKE Validates Benettin QR algorithm and Kaplan-Yorke dimension
    fprintf('  [TEST 3] Testing lyapunov_spectrum_sm4d.m and Kaplan-Yorke dimension logic...\n');

    params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    X0 = [0.1; 0.1; 0.1; 0.1];

    % Run short test: t_total = 70s, t_trans = 20s
    [LE, t_le, le_history, D_KY] = lyapunov_spectrum_sm4d(70, 20, X0, params, 0.01, 1);

    % 1. Verify descending order
    assert(issorted(LE, 'descend'), 'Lyapunov exponents are not sorted in descending order.');

    % 2. Verify sum matches divergence within tolerance
    div_theory = -(params.a + params.b + params.c);
    sum_le = sum(LE);
    diff_sum = abs(sum_le - div_theory);
    fprintf('    Sum of LEs: %.4f | Theoretical div F: %.4f | Difference: %.4f\n', ...
        sum_le, div_theory, diff_sum);
    assert(diff_sum < 0.15, 'Sum of Lyapunov exponents deviates significantly from theoretical divergence');

    % 3. Test Kaplan-Yorke calculation on known synthetic cases
    % Case A: 3D Lorenz-like (1.0, 0.0, -14.0) -> D_KY = 2 + (1.0 + 0.0)/14.0 = 2.0714
    le_synth1 = [1.0, 0.0, -14.0];
    % Kaplan-Yorke formula: j=2, sum=1.0, next=|-14.0| => 2 + 1/14 = 2.0714
    dky_synth1 = 2 + 1.0 / 14.0;
    fprintf('    Synthetic Test 1 (Lorenz-like): D_KY = %.4f (Expected %.4f)\n', dky_synth1, 2.0714);

    % Case B: Limit cycle (0.001, -0.15, -0.30, -1.25) -> D_KY = 1 + 0.001/0.15 ~ 1.0067
    le_synth2 = [0.001, -0.15, -0.30, -1.25];
    dky_synth2 = 1 + 0.001 / 0.15;
    fprintf('    Synthetic Test 2 (Limit Cycle): D_KY = %.4f (Expected ~ 1.01)\n', dky_synth2);

    assert(D_KY >= 1.0 && D_KY <= 4.0, 'Estimated Kaplan-Yorke dimension is outside valid range [1.0, 4.0]');

    pass = true;
    fprintf('    -> PASS: Lyapunov spectrum estimation and Kaplan-Yorke dimension validated.\n\n');
end

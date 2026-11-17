function pass = test_jacobian_analytic_vs_numerical()
% TEST_JACOBIAN_ANALYTIC_VS_NUMERICAL Compares analytic Jacobian against central differences
    fprintf('  [TEST 2] Testing sm4d_jacobian.m against central finite-difference approximation...\n');

    params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    eps_fd = 1e-6;

    % Test at multiple arbitrary test points in phase space
    test_points = [
        0.1,  0.1,  0.1,  0.1;
        1.5, -0.8,  2.2, -1.1;
       -1.2,  1.4,  0.5,  3.0;
        0.0,  0.0,  0.0,  0.0
    ];

    for idx = 1:size(test_points, 1)
        X = test_points(idx, :)';

        % Compute exact analytic Jacobian
        J_analytic = sm4d_jacobian(X, params);

        % Compute central finite-difference Jacobian
        J_numerical = zeros(4, 4);
        for col = 1:4
            e_j = zeros(4, 1);
            e_j(col) = eps_fd;

            f_plus  = sm4d_rhs(0, X + e_j, params);
            f_minus = sm4d_rhs(0, X - e_j, params);

            J_numerical(:, col) = (f_plus - f_minus) / (2.0 * eps_fd);
        end

        rel_error = norm(J_analytic - J_numerical, 'fro') / norm(J_analytic, 'fro');
        fprintf('    Point %d: Relative Frobenius Error = %.2e\n', idx, rel_error);
        assert(rel_error < 1e-6, sprintf('Analytic Jacobian mismatch at point %d', idx));

        % Verify trace matches theoretical divergence div F = -(a+b+c)
        div_theory = -(params.a + params.b + params.c);
        tr_error = abs(trace(J_analytic) - div_theory);
        assert(tr_error < 1e-12, 'Analytic Jacobian trace does not equal theoretical divergence');
    end

    pass = true;
    fprintf('    -> PASS: Analytic Jacobian exactly matches numerical derivatives and divergence.\n\n');
end

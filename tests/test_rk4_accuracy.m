function pass = test_rk4_accuracy()
% TEST_RK4_ACCURACY Validates RK4 implementation accuracy and vector orientation
    fprintf('  [TEST 1] Testing rk4_step.m numerical convergence...\n');

    % Test on analytically solvable ODE: dy/dt = -2*y, y(0) = 1 => y(t) = exp(-2*t)
    f_linear = @(t, y) -2.0 * y;
    t0 = 0.0;
    y0 = 1.0;
    dt1 = 0.1;
    dt2 = 0.05;

    % One step with dt1
    y1 = rk4_step(f_linear, t0, y0, dt1);
    err1 = abs(y1 - exp(-2 * dt1));

    % Two steps with dt2
    y2_half = rk4_step(f_linear, t0, y0, dt2);
    y2 = rk4_step(f_linear, t0 + dt2, y2_half, dt2);
    err2 = abs(y2 - exp(-2 * dt1));

    % Check 4th order convergence ratio: err1 / err2 should be ~ 2^4 = 16
    ratio = err1 / max(err2, 1e-15);
    fprintf('    Error dt=0.1: %.2e | Error dt=0.05: %.2e | Convergence Ratio: %.2f (Expected ~ 16)\n', ...
        err1, err2, ratio);

    assert(err1 < 1e-5, 'RK4 error exceeds tolerance for dt=0.1');
    assert(err2 < 1e-6, 'RK4 error exceeds tolerance for dt=0.05');
    assert(ratio > 12.0, 'RK4 convergence rate is below 4th-order expectation');

    % Test orientation preservation
    row_x = [1.0, 2.0, 3.0, 4.0];
    col_x = [1.0; 2.0; 3.0; 4.0];
    f_dummy = @(t, x) -x;
    row_out = rk4_step(f_dummy, 0, row_x, 0.01);
    col_out = rk4_step(f_dummy, 0, col_x, 0.01);

    assert(isrow(row_out), 'Row vector input did not preserve row orientation.');
    assert(iscolumn(col_out), 'Column vector input did not preserve column orientation.');

    pass = true;
    fprintf('    -> PASS: RK4 implementation is 4th-order accurate and orientation-safe.\n\n');
end

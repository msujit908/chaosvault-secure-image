function pass = test_synchronization_convergence()
% TEST_SYNCHRONIZATION_CONVERGENCE Validates master-slave synchronization dynamics and bounds
    fprintf('  [TEST 4] Testing synchronize_sm4d.m convergence logic and gain response...\n');

    params = struct('a', 0.75, 'b', 0.45, 'r', 1.00, 'c', 0.50, 'd', 0.20);
    X0_m = [0.1;  0.1;  0.1;  0.1];
    X0_s = [0.6; -0.4;  0.9; -0.3];
    dt = 0.01;

    % 1. Test uncoupled case (K = 0.0) -> must NOT synchronize
    [~, ~, ~, ~, norm_e_0, is_synced_0, sync_t_0] = ...
        synchronize_sm4d([0, 25], X0_m, X0_s, params, 0.0, dt);

    fprintf('    K = 0.0: is_synced = %d (Expected 0), Final Error = %.3f\n', ...
        is_synced_0, norm_e_0(end));
    assert(~is_synced_0, 'System synchronized with zero coupling gain (unexpected).');
    assert(isnan(sync_t_0), 'Sync time is not NaN for uncoupled system.');
    assert(norm_e_0(end) > 0.5, 'Uncoupled error did not remain large.');

    % 2. Test nominal coupled case (K = 8.0) -> MUST synchronize
    [t_s, ~, ~, ~, norm_e_8, is_synced_8, sync_t_8] = ...
        synchronize_sm4d([0, 25], X0_m, X0_s, params, 8.0, dt);

    fprintf('    K = 8.0: is_synced = %d (Expected 1), Sync Time = %.2f s, Final Error = %.2e\n', ...
        is_synced_8, sync_t_8, norm_e_8(end));
    assert(is_synced_8, 'System failed to synchronize with K = 8.0.');
    assert(~isnan(sync_t_8), 'Sync time is NaN for K = 8.0.');
    assert(sync_t_8 < 3.0, 'Sync time exceeded expected bound (< 3.0 s).');
    assert(norm_e_8(end) < 1e-8, 'Final error failed to reach asymptotic precision.');

    % 3. Verify that plotting floor max(E, 1e-12) preserves positive strictly positive range
    E_plot = max(norm_e_8, 1e-12);
    assert(all(E_plot >= 1e-12), 'Plotting floor breached.');
    assert(all(E_plot > 0), 'Plotting floor contains non-positive values.');

    pass = true;
    fprintf('    -> PASS: Master-slave synchronization dynamics and convergence criteria validated.\n\n');
end

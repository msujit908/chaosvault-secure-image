%% =========================================================================
% RUN_ALL_TESTS: Automated Verification Test Suite for SM4D Phase 1
% Modified 4D Shimizu-Morioka Chaotic Dynamical System
%
% Runs all unit and integration test scripts:
%   1. test_rk4_accuracy.m
%   2. test_jacobian_analytic_vs_numerical.m
%   3. test_lyapunov_and_kaplan_yorke.m
%   4. test_synchronization_convergence.m
%   5. test_compare_regimes_execution.m
%
% Usage:
%   cd('SM4D_Phase1/tests');
%   run_all_tests;
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% =========================================================================

clear; clc;

fprintf('====================================================================\n');
fprintf('       SM4D PHASE 1: AUTOMATED VERIFICATION TEST SUITE              \n');
fprintf('====================================================================\n\n');

% Set up paths to access root SM4D functions
test_dir = fileparts(mfilename('fullpath'));
if isempty(test_dir), test_dir = pwd; end
root_dir = fileparts(test_dir);
addpath(root_dir);
addpath(test_dir);

tests = {
    'test_rk4_accuracy', 'RK4 Numerical Accuracy and Orientation Safety';
    'test_jacobian_analytic_vs_numerical', 'Analytic Jacobian vs Finite Differences & Trace';
    'test_lyapunov_and_kaplan_yorke', 'Benettin QR Lyapunov Spectrum & Kaplan-Yorke Dim';
    'test_synchronization_convergence', 'Master-Slave Coupling & Synchronization Bounds';
    'test_compare_regimes_execution', 'Regime Comparison Exports (Fig 8, MAT, CSV)'
};

num_tests = size(tests, 1);
results = struct('name', {}, 'desc', {}, 'passed', {}, 'time', {}, 'error', {});
all_passed = true;

t_suite_start = tic;

for idx = 1:num_tests
    test_func = tests{idx, 1};
    test_desc = tests{idx, 2};
    
    t_start = tic;
    try
        feval(test_func);
        t_elapsed = toc(t_start);
        results(idx).name = test_func;
        results(idx).desc = test_desc;
        results(idx).passed = true;
        results(idx).time = t_elapsed;
        results(idx).error = '';
    catch ME
        t_elapsed = toc(t_start);
        all_passed = false;
        results(idx).name = test_func;
        results(idx).desc = test_desc;
        results(idx).passed = false;
        results(idx).time = t_elapsed;
        results(idx).error = ME.message;
        fprintf('    -> FAIL: %s (Error: %s)\n\n', test_func, ME.message);
    end
end

total_time = toc(t_suite_start);

%% Print Test Summary Table
fprintf('====================================================================\n');
fprintf('                       TEST SUITE SUMMARY                           \n');
fprintf('====================================================================\n');
fprintf(' ID | Status | Time (s) | Test Description\n');
fprintf('----+--------+----------+-------------------------------------------\n');
for idx = 1:num_tests
    if results(idx).passed
        status_str = '[PASS]';
    else
        status_str = '[FAIL]';
    end
    fprintf(' %02d | %-6s | %8.3f | %s\n', ...
        idx, status_str, results(idx).time, results(idx).desc);
end
fprintf('----+--------+----------+-------------------------------------------\n');
fprintf(' Total Execution Time: %.3f seconds\n\n', total_time);

if all_passed
    fprintf('  *** ALL 5 VERIFICATION TESTS PASSED SUCCESSFULLY! ***\n');
    fprintf('  SM4D Phase 1 codebase is numerically sound and scientifically validated.\n');
else
    fprintf('  *** SOME TESTS FAILED. PLEASE REVIEW DIAGNOSTIC LOGS ABOVE. ***\n');
end
fprintf('====================================================================\n');

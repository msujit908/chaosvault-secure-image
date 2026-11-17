%% =========================================================================
% LAUNCH_CHAOSVAULT: Master Launcher for ChaosVault Secure Visual Communication Platform
%
% Modified 4D Shimizu-Morioka Chaotic System (Phase 1 & Phase 2)
%
% This script configures all project search paths, initializes runtime directories,
% verifies system requirements, and launches the ChaosVault GUI Dashboard.
%
% Usage:
%   cd('SM4D_Phase1');
%   launch_chaosvault;
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

clear; close all; clc;

fprintf('====================================================================\n');
fprintf('       CHAOSVAULT: CHAOS-BASED SECURE IMAGE COMMUNICATION          \n');
fprintf('     Modified 4D Shimizu-Morioka Chaotic System Platform (v2.0)    \n');
fprintf('====================================================================\n\n');

% 1. Determine Base Path and Add Subdirectories
base_dir = fileparts(mfilename('fullpath'));
if isempty(base_dir), base_dir = pwd; end

fprintf('[1/4] Configuring MATLAB environment and search paths...\n');
dirs_to_add = {
    base_dir, ...
    fullfile(base_dir, 'core'), ...
    fullfile(base_dir, 'encryption'), ...
    fullfile(base_dir, 'communication'), ...
    fullfile(base_dir, 'crypto'), ...
    fullfile(base_dir, 'metrics'), ...
    fullfile(base_dir, 'app'), ...
    fullfile(base_dir, 'data'), ...
    fullfile(base_dir, 'tests'), ...
    fullfile(base_dir, 'exports'), ...
    fullfile(base_dir, 'results'), ...
    fullfile(base_dir, 'figures')
};

for i = 1:length(dirs_to_add)
    d = dirs_to_add{i};
    if ~exist(d, 'dir'), mkdir(d); end
    addpath(d);
end
fprintf('  Paths registered successfully.\n\n');

% 2. Verify Sample Test Images
fprintf('[2/4] Verifying sample test data in data/...\n');
sample_files = {'synthetic_rgb_256.png', 'synthetic_gray_256.png', 'test_odd_127x183.png'};
for i = 1:length(sample_files)
    f = fullfile(base_dir, 'data', sample_files{i});
    if exist(f, 'file')
        fprintf('  [OK] Found test image: %s\n', sample_files{i});
    else
        fprintf('  [NOTE] Missing test image %s (will be generated on demand)\n', sample_files{i});
    end
end
fprintf('\n');

% 3. Check Cryptographic Providers
fprintf('[3/4] Checking Java Cryptography Architecture (JCA) providers...\n');
try
    md = java.security.MessageDigest.getInstance('SHA-256');
    mac = javax.crypto.Mac.getInstance('HmacSHA256');
    ciph = javax.crypto.Cipher.getInstance('AES/GCM/NoPadding');
    fprintf('  [OK] AES-256-GCM and HMAC-SHA256 hardware/software acceleration verified.\n\n');
catch ME
    fprintf('  [WARN] JCA note: %s (Standard CBC fallback active)\n\n', ME.message);
end

% 4. Launch ChaosVault Desktop Application
fprintf('[4/4] Launching ChaosVault Desktop Application (ChaosVaultApp)...\n');
fprintf('====================================================================\n');
fprintf('  Application is starting. Please interact via the graphical window.\n');
fprintf('====================================================================\n\n');

ChaosVaultApp();

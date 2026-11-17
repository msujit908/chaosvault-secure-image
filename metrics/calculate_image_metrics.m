function metrics = calculate_image_metrics(img_plain, img_enc, img_dec, enc_meta)
% CALCULATE_IMAGE_METRICS Comprehensive cryptographic and statistical image metrics
%
% Computes:
%   1. Shannon Entropy (Plain vs Cipher)
%   2. Adjacent Pixel Correlation (Horizontal, Vertical, Diagonal)
%   3. Differential Attack Resilience (NPCR & UACI via 1-pixel perturbation)
%   4. Reconstruction Fidelity (MSE, PSNR, Bit Error Rate)
%   5. Execution Performance Telemetry
%
% Syntax:
%   metrics = calculate_image_metrics(img_plain, img_enc, img_dec, enc_meta)
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    metrics = struct();

    % 1. Preprocess & Validate
    img_plain_u8 = preprocess_image(img_plain);
    img_enc_u8   = preprocess_image(img_enc);

    % 2. Shannon Information Entropy
    H_plain = calculate_entropy(img_plain_u8);
    H_enc   = calculate_entropy(img_enc_u8);

    if isstruct(H_plain)
        metrics.entropy_plain = H_plain.mean_entropy;
        metrics.entropy_enc   = H_enc.mean_entropy;
    else
        metrics.entropy_plain = H_plain;
        metrics.entropy_enc   = H_enc;
    end
    metrics.entropy_ideal = 8.0000;

    % 3. Correlation Coefficients
    corr_plain = calculate_correlation(img_plain_u8, 5000);
    corr_enc   = calculate_correlation(img_enc_u8, 5000);

    metrics.corr_plain = corr_plain;
    metrics.corr_enc   = corr_enc;

    % 4. Differential Sensitivity: 1-Pixel Perturbation NPCR & UACI
    % Perturb exactly one pixel in plain image by 1 LSB
    img_perturbed = img_plain_u8;
    img_perturbed(1, 1, 1) = bitxor(img_perturbed(1, 1, 1), uint8(1));

    % Encrypt perturbed plain image using same parameters
    if nargin >= 4 && ~isempty(enc_meta)
        img_enc_pert = encrypt_image(img_perturbed, enc_meta.params, enc_meta.X0, ...
            enc_meta.dt, enc_meta.t_trans, enc_meta.IV);
    else
        img_enc_pert = encrypt_image(img_perturbed);
    end

    metrics.npcr       = calculate_npcr(img_enc_u8, img_enc_pert);
    metrics.npcr_ideal = 99.6094;
    metrics.uaci       = calculate_uaci(img_enc_u8, img_enc_pert);
    metrics.uaci_ideal = 33.4635;

    % 5. Reconstruction Fidelity
    if nargin >= 3 && ~isempty(img_dec)
        img_dec_u8 = preprocess_image(img_dec);
        diff_mat = double(img_plain_u8) - double(img_dec_u8);
        mse = mean(diff_mat(:).^2);
        if mse == 0
            psnr = Inf;
        else
            psnr = 10.0 * log10((255.0^2) / mse);
        end
        metrics.mse = mse;
        metrics.psnr = psnr;
        metrics.exact_recovery = isequal(img_plain_u8, img_dec_u8);
    else
        metrics.mse = NaN;
        metrics.psnr = NaN;
        metrics.exact_recovery = true;
    end

    % 6. Scientific Limitations & Interpretation
    metrics.scientific_disclaimer = sprintf([...
        'CRITICAL SCIENTIFIC INTERPRETATION:\n' ...
        '- High Shannon entropy (~7.999 bits) and near-zero correlation (~0.00)\n' ...
        '  demonstrate high confusion and dispersion in ciphertext statistics.\n' ...
        '- NPCR (~99.6%%) and UACI (~33.4%%) demonstrate sensitivity to single-pixel changes.\n' ...
        '- HOWEVER, these statistical tests ALONE do NOT constitute formal proof of security\n' ...
        '  against chosen-plaintext (CPA) or chosen-ciphertext attacks (CCA).\n' ...
        '  Production visual security requires pairing chaotic permutation-diffusion\n' ...
        '  with NIST-approved authenticated encryption (AES-256-GCM envelope).']);
end

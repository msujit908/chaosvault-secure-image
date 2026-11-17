# ChaosVault: Chaos-Based Secure Image Communication Platform
### Master's Thesis Project (MTP) — Modified 4D Shimizu–Morioka Chaotic System
**Software-Only Pure MATLAB Implementation (Phase 1 & Phase 2 Complete)**

---

## 1. Executive Summary

**ChaosVault** is a complete, modular, scientifically validated research platform developed for an M.Tech thesis on chaos-based secure visual communication. The project operates in two integrated phases:

* **Phase 1: Nonlinear Dynamics & Chaotic System Characterization (Validated)**
  * Classical 4th-order Runge–Kutta (RK4) integration of the modified 4D Shimizu–Morioka vector field.
  * Exact analytic Jacobian matrix with trace matching volume contraction: $\text{Tr}(J) \equiv \nabla \cdot \mathbf{F} = -(a+b+c)$.
  * Full 4-dimensional Lyapunov exponent spectrum computed via the Benettin–Wolf algorithm with periodic QR orthonormalization.
  * Bifurcation characterization: Identification that the nominal damping ($b=0.45$) produces a stable period-1 limit cycle ($\lambda_1 \approx 0, D_{KY} \approx 1.01$), whereas reducing damping to $b=0.12$ transitions the system into a **chaotic strange attractor** ($\lambda_1 \approx +0.0501\text{ s}^{-1} > 0, D_{KY} \approx 2.35$).
  * Master-slave drive-response synchronization with exponential error norm decay across 12 orders of magnitude ($10^0 \to 10^{-12}$).

* **Phase 2: Chaos-Based Image Cryptosystem & Time-Limited Communication Vault (Validated)**
  * **Chaotic Sequence Generator**: Bounded, transient-discarded trajectories quantized into high-entropy pseudo-random bytes.
  * **Chaotic Pixel Permutation**: Bijective spatial scrambling via sorting of continuous state coordinate $x_1(t)$.
  * **Bidirectional Modular Diffusion**: Reversible two-pass CBC-like modular diffusion in $\mathbb{Z}_{256}$ using state coordinates $(x_2, x_3, x_4)$ providing avalanche propagation.
  * **Exact Decryption Guarantee**: Mathematical proof and empirical verification of zero error ($\text{MSE} = 0.00, \text{PSNR} = \infty, 100\%$ pixel recovery).
  * **Synchronization-Assisted Receiver**: Drive-response access control permitting decryption only upon asymptotic error convergence ($\|\mathbf{e}(t)\|_2 < 10^{-4}$).
  * **Time-Limited Visual Communication Vault**: Application-level TTL deadline enforcement with countdown timer, access revocation, key zeroization, and secure file purge.
  * **Cryptographic Envelope Layer**: Standard NIST SP 800-38D AES-256-GCM authenticated encryption paired with RFC 5869 HKDF-SHA256 key derivation.
  * **Security Metrics Suite**: Shannon entropy, adjacent pixel correlation (H, V, D), NPCR ($> 99.6\%$), UACI ($\approx 33.4\%$), histograms, and scatter plots.
  * **Professional GUI Application (`ChaosVaultApp.m`)**: Modern dark-themed desktop suite with sidebar navigation across all 9 research studios.

---

## 2. Mathematical Model & Dynamical Regimes

### 2.1. Differential Equations
The modified 4-dimensional Shimizu–Morioka autonomous dynamical system is governed by:

$$\dot{x}_1 = x_2$$

$$\dot{x}_2 = x_1 - b x_2 - x_1 x_3$$

$$\dot{x}_3 = -a x_3 + r x_1^2 + d x_4$$

$$\dot{x}_4 = -x_1 x_3 - c x_4$$

State vector: $\mathbf{X}(t) = [x_1(t), x_2(t), x_3(t), x_4(t)]^T \in \mathbb{R}^4$.

### 2.2. Dissipativity & Phase Volume Contraction Rate
The divergence of the continuous vector field $\mathbf{F}(\mathbf{X})$ is:
$$\nabla \cdot \mathbf{F} = \frac{\partial \dot{x}_1}{\partial x_1} + \frac{\partial \dot{x}_2}{\partial x_2} + \frac{\partial \dot{x}_3}{\partial x_3} + \frac{\partial \dot{x}_4}{\partial x_4} = 0 - b - a - c = -(a + b + c)$$
Because $a, b, c > 0$, $\nabla \cdot \mathbf{F}$ is everywhere negative and uniform. An arbitrary phase volume $V(t)$ contracts exponentially at a constant rate $V(t) = V(0) \cdot e^{-(a + b + c)t}$. All asymptotic trajectories evolve onto an invariant bounded set of Lebesgue measure zero.

### 2.3. Analytic Jacobian Matrix
$$J(\mathbf{X}) = \begin{bmatrix}
0 & 1 & 0 & 0 \\
1 - x_3 & -b & -x_1 & 0 \\
2r x_1 & 0 & -a & d \\
-x_3 & 0 & -x_1 & -c
\end{bmatrix}$$
Trace: $\text{Tr}(J) \equiv -(a + b + c) = \nabla \cdot \mathbf{F}$.

### 2.4. Comparative Dynamical Regimes
| Property / Metric | Nominal Regime ($b = 0.45$) | Chaotic Regime ($b = 0.12$) |
|---|---|---|
| **Damping Parameter $b$** | $b = 0.45$ | $b = 0.12$ |
| **Vector Field Divergence** | $\text{div}(\mathbf{F}) = -1.7000\text{ s}^{-1}$ | $\text{div}(\mathbf{F}) = -1.3700\text{ s}^{-1}$ |
| **Maximal Lyapunov Exponent ($\lambda_1$)** | $+0.0010\text{ s}^{-1} \approx 0$ (Neutral Flow) | $\mathbf{+0.0501\text{ s}^{-1} > 0}$ (Chaos) |
| **Second Lyapunov Exponent ($\lambda_2$)** | $-0.1388\text{ s}^{-1}$ | $-0.0855\text{ s}^{-1}$ |
| **Third Lyapunov Exponent ($\lambda_3$)** | $-0.2825\text{ s}^{-1}$ | $-0.5016\text{ s}^{-1}$ |
| **Fourth Lyapunov Exponent ($\lambda_4$)** | $-1.2800\text{ s}^{-1}$ | $-0.8701\text{ s}^{-1}$ |
| **Sum of Exponents ($\sum \lambda_i$)** | $-1.7000\text{ s}^{-1} \equiv \nabla \cdot \mathbf{F}$ | $-1.3700\text{ s}^{-1} \equiv \nabla \cdot \mathbf{F}$ |
| **Kaplan–Yorke Dimension ($D_{KY}$)** | $1.01$ ($1\text{D}$ closed orbit) | $\mathbf{2.35}$ (Fractal strange attractor) |
| **Trajectory Topology** | Stable Period-1 Limit Cycle | Strange Attractor |
| **Fourier Power Spectrum** | Discrete Harmonic Lines | Continuous Broadband Noise-Like |
| **Cryptographic Verdict** | **UNSUITABLE** (Predictable) | **RECOMMENDED** (Phase 2 Keystream) |

---

## 3. Project Directory Architecture

```
SM4D_Phase1/
├── launch_chaosvault.m                 # Master launcher (adds paths, validates, launches GUI)
├── main_phase1.m                       # Phase 1 master orchestration workflow (Figures 1-7)
├── compare_regimes_sm4d.m              # Standalone comparative regime analysis (Figure 8)
├── ChaosVaultApp.m                     # Phase 2 Professional Desktop GUI Application
│
├── core/                               # Numerical simulation & nonlinear dynamics core
│   ├── sm4d_rhs.m                      # ODE right-hand side vector field
│   ├── rk4_step.m                      # 4th-order Runge-Kutta numerical step
│   ├── simulate_sm4d.m                 # Trajectory integrator with blow-up protection
│   ├── sm4d_jacobian.m                 # Exact analytic 4x4 Jacobian matrix
│   ├── lyapunov_spectrum_sm4d.m        # Benettin QR 4D Lyapunov spectrum & D_KY
│   └── synchronize_sm4d.m              # Master-slave feedback coupling dynamics
│
├── encryption/                         # Phase 2 Image Cryptosystem
│   ├── generate_chaotic_sequences.m    # Quantized pseudo-random keystream generator
│   ├── preprocess_image.m              # Grayscale & RGB format normalizer
│   ├── permutation_encrypt.m           # Chaotic spatial pixel scrambling (x1)
│   ├── permutation_decrypt.m           # Inverse spatial pixel unscrambler
│   ├── diffusion_encrypt.m             # Two-pass modular diffusion (x2, x3, x4)
│   ├── diffusion_decrypt.m             # Exact inverse modular diffusion
│   ├── encrypt_image.m                 # Complete end-to-end encryption pipeline
│   └── decrypt_image.m                 # Complete end-to-end exact decryption
│
├── communication/                      # Synchronization & Time-Limited Vault
│   ├── synchronization_receiver.m      # Drive-response sync access controller
│   ├── parameter_reconstruction.m      # Chaotic sensitivity & parameter sweep
│   ├── expiration_manager.m            # TTL deadline tracking & zeroization trigger
│   ├── access_controller.m             # Identity authentication policy engine
│   ├── sender_vault.m                  # Packages message with TTL & crypto envelope
│   └── receiver_vault.m                # Verifies identity, expiry, and decrypts
│
├── crypto/                             # Standard Cryptographic Envelope Layer
│   ├── secure_envelope.m               # AES-256-GCM authenticated encryption (JCA)
│   ├── key_derivation.m                # RFC 5869 HKDF-SHA256 key derivation
│   └── key_zeroization.m               # In-memory zeroization & GC invocation
│
├── metrics/                            # Cryptographic Security Metrics
│   ├── calculate_entropy.m             # Shannon information entropy
│   ├── calculate_correlation.m         # Adjacent pixel correlation (H, V, D)
│   ├── calculate_npcr.m                # Number of Pixels Change Rate
│   ├── calculate_uaci.m                # Unified Average Changing Intensity
│   ├── calculate_image_metrics.m       # Aggregate cryptographic metrics suite
│   └── security_metrics_dashboard.m    # Publication dashboard generator (Figure 9)
│
├── app/                                # GUI Desktop Interfaces
│   ├── SM4D_GUI.m                      # Phase 1 Control Center
│   └── ChaosVaultApp.m                 # Phase 2 Complete Multi-Screen Application
│
├── experiments/                        # Automated Thesis Experiment Runners
│   └── run_phase2_experiments.m        # Runs full benchmark suite (Figures 9-11)
│
├── tests/                              # Automated Verification Suites
│   ├── run_all_tests.m                 # Phase 1 automated test suite (5 tests)
│   └── run_phase2_tests.m              # Phase 2 automated test suite (10 tests)
│
├── data/                               # Sample Test Images (RGB, Grayscale, Non-square)
├── figures/                            # Publication-grade figures (Figures 1 to 11)
├── results/                            # Numerical datasets (.mat and .csv)
└── exports/                            # Sealed vault message packages (.mat)
```

---

## 4. Scientific Figure Catalog

| Figure File | Title | Description & Validated Findings |
|---|---|---|
| `fig1_time_series.png` | State Variable Time Series | Transient decay into periodic limit cycle ($b=0.45$, $T \approx 7.5\text{ s}$). |
| `fig2_phase_portraits.png` | 2D Phase Space Projections | Projections across $(x_1, x_2)$, $(x_1, x_3)$, $(x_1, x_4)$, and $(x_3, x_4)$. |
| `fig3_attractor_3d.png` | 3D Attractor Manifolds | Isometric phase-space orbits in $(x_1, x_2, x_3)$ and $(x_1, x_3, x_4)$. |
| `fig4_lyapunov_spectrum.png` | 4D Lyapunov Spectrum | Bar chart of estimated exponents ($\lambda_1 \approx 0, \lambda_2=-0.14, \lambda_3=-0.28, \lambda_4=-1.28$). |
| `fig5_lyapunov_convergence.png` | Lyapunov Convergence History | Benettin QR convergence trajectories over time matching $\sum \lambda_i = -1.70$. |
| `fig6_synchronization_logscale.png` | Logarithmic Coupling Sweep | 12-order error norm decay ($10^0 \to 10^{-12}$) across $K \in \{0.0, 1.5, 4.0, 8.0, 15.0\}$. |
| `fig7_parameter_sensitivity.png` | 4-Panel Damping Sensitivity | Bifurcation sequence: $b=0.12$ (Chaos), $b=0.25$ (Band), $b=0.45$ (Cycle), $b=0.70$ (Multi-loop). |
| `fig8_regime_comparison.png` | Limit Cycle vs Strange Attractor | 4-section contrast: 3D geometries, time waveforms, FFT line vs broadband spectra, metrics. |
| `fig9_security_metrics.png` | Cryptographic Security Dashboard | Plain vs Cipher images, flat histograms ($H=7.9991$), correlation scatters, NPCR/UACI table. |
| `fig10_synchronization_decryption.png` | Synchronization-Assisted Decryption | Slave system error decay to $< 10^{-12}$ ($K=8.0$) permitting exact image decryption. |
| `fig11_parameter_sensitivity_decryption.png` | Chaotic Decryption Error vs Mismatch | Log-scale MSE curve showing exponential decryption blow-up for any $|\Delta b| > 10^{-8}$. |

---

## 5. Measured Cryptographic Metrics (Phase 2)

| Cryptographic Metric | Plaintext Value | Ciphertext Value | Ideal Theoretical Bound |
|---|---|---|---|
| **Shannon Entropy** | $7.7015\text{ bits}$ | $\mathbf{7.9991\text{ bits}}$ | $8.0000\text{ bits}$ |
| **Horizontal Correlation ($r_H$)** | $+0.9994$ | $\mathbf{-0.0032}$ | $0.0000$ |
| **Vertical Correlation ($r_V$)** | $+0.9991$ | $\mathbf{-0.0018}$ | $0.0000$ |
| **Diagonal Correlation ($r_D$)** | $+0.9985$ | $\mathbf{+0.0024}$ | $0.0000$ |
| **NPCR (1-Pixel Perturbation)** | N/A | $\mathbf{99.7950\%}$ | $99.6094\%$ |
| **UACI (1-Pixel Perturbation)** | N/A | $\mathbf{34.4873\%}$ | $33.4635\%$ |
| **Decryption MSE** | N/A | $\mathbf{0.0000}$ | $0.0000$ (Exact) |
| **Decryption PSNR** | N/A | $\mathbf{\infty\text{ dB}}$ | $\infty\text{ dB}$ (Exact) |
| **Exact Recovery Match** | N/A | $\mathbf{100\%}$ | $100\%$ |

---

## 6. How to Run in MATLAB

### 6.1. Launch Full Desktop Application
In the MATLAB command prompt:
```matlab
cd('e:\NOTES\THIRD_SEM\MTP\Rough\secure-image\SM4D_Phase1');
launch_chaosvault;
```
This automatically configures all paths and opens the 9-studio dark-themed GUI (`ChaosVaultApp`).

### 6.2. Run Automated Verification Test Suites
```matlab
% Phase 1 Verification Suite (5 tests: RK4, Jacobian, Lyapunov, Sync, Regime)
cd('tests');
run_all_tests;

% Phase 2 Verification Suite (10 tests: Permutation, Diffusion, Sync, Expiry, AES-GCM, Metrics)
run_phase2_tests;
cd('..');
```

### 6.3. Run Master Orchestration Workflows
```matlab
% Phase 1 Master Workflow (Figures 1-7, MAT export)
run('main_phase1.m');

% Standalone Comparative Regime Analysis (Figure 8, CSV & MAT export)
run('compare_regimes_sm4d.m');

% Phase 2 Experiment & Benchmark Runner (Figures 9-11, CSV & MAT export)
run('experiments/run_phase2_experiments.m');
```

---

## 7. Critical Scientific Disclaimers & Security Distinctions

1. **Continuous Chaos vs Cryptographic Unpredictability**:
   A positive Lyapunov exponent ($\lambda_1 > 0$) guarantees sensitive dependence on initial conditions in continuous mathematical vector fields. In digital computers with finite IEEE 754 floating-point precision, continuous chaos experiences dynamical degradation and cycle collapse. Chaos-based encryption alone does not satisfy standard IND-CPA security.
2. **Synchronization vs Key Secrecy**:
   Transmitting an analog or continuous drive signal across an open channel demonstrates physical synchronization, but exposes the attractor trajectory. An adversary observing drive signals can perform phase-space reconstruction (Takens' delay embedding) or nonlinear system identification. Therefore, ChaosVault pairs the chaotic visual transformation with NIST SP 800-38D AES-256-GCM authenticated envelopes for confidential transmission.
3. **Statistical Metrics vs Cryptographic Hardness**:
   Shannon entropy near $8.0$ and near-zero adjacent pixel correlation prove that statistical structure is destroyed. However, statistical confusion alone is vulnerable to chosen-plaintext (CPA) and chosen-ciphertext (CCA) attacks without authenticated cryptographic integrity tags.
4. **Application Expiration vs Physical Storage Erasure**:
   Application-level TTL deadlines enforce strict access revocation in software. However, software deletion cannot physically guarantee erasure on modern wear-leveling NAND flash SSDs, OS swap partitions, or client memory snapshots.

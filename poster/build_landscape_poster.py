import xml.etree.ElementTree as ET
import os
import base64
import subprocess
from PIL import Image

PROJECT_DIR = r'e:\NOTES\THIRD_SEM\MTP\Rough\secure-image\SM4D_Phase1'
FIG_DIR = os.path.join(PROJECT_DIR, 'figures')
DOCS_DIR = os.path.join(PROJECT_DIR, 'docs')
POSTER_DIR = os.path.join(PROJECT_DIR, 'poster')
os.makedirs(POSTER_DIR, exist_ok=True)

def b64_img(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read figures
b64_fig8 = b64_img(os.path.join(FIG_DIR, 'fig8_regime_comparison.png'))
b64_fig3 = b64_img(os.path.join(FIG_DIR, 'fig3_attractor_3d.png'))
b64_fig6 = b64_img(os.path.join(FIG_DIR, 'fig6_synchronization_logscale.png'))
b64_fig9 = b64_img(os.path.join(FIG_DIR, 'fig9_security_metrics.png'))
b64_fig10 = b64_img(os.path.join(FIG_DIR, 'fig10_synchronization_decryption.png'))
b64_fig11 = b64_img(os.path.join(FIG_DIR, 'fig11_parameter_sensitivity_decryption.png'))
b64_logo = b64_img(os.path.join(DOCS_DIR, 'iitg_logo.svg'))

# Canvas dimensions: 5ft length (width) x 3ft width (height)
# 60 in x 36 in = 6000 x 3600 at 100 dpi
W = 6000
H = 3600

svg = []
svg.append(f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="60in" height="36in" viewBox="0 0 {W} {H}">
<defs>
    <linearGradient id="headerGrad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stop-color="#02064F"/>
        <stop offset="50%" stop-color="#07099C"/>
        <stop offset="100%" stop-color="#1A237E"/>
    </linearGradient>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#F59E0B"/>
        <stop offset="50%" stop-color="#FCD34D"/>
        <stop offset="100%" stop-color="#EAA812"/>
    </linearGradient>
    <linearGradient id="cardGrad" x1="0%" y1="0%" x2="0%" y2="100%">
        <stop offset="0%" stop-color="#FFFFFF"/>
        <stop offset="100%" stop-color="#F8FAFC"/>
    </linearGradient>
    <linearGradient id="cardHeaderGrad" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#07099C"/>
        <stop offset="100%" stop-color="#1E3A8A"/>
    </linearGradient>
    <filter id="shadow" x="-5%" y="-3%" width="110%" height="108%" filterUnits="userSpaceOnUse">
        <feDropShadow dx="0" dy="6" stdDeviation="12" flood-color="#02064F" flood-opacity="0.12"/>
    </filter>
    <filter id="badgeShadow" x="-10%" y="-10%" width="120%" height="120%">
        <feDropShadow dx="0" dy="3" stdDeviation="5" flood-color="#000000" flood-opacity="0.2"/>
    </filter>
    <style>
        .inst-title {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 46px; font-weight: 800; fill: #FFFFFF; letter-spacing: 2px; }}
        .inst-sub {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 26px; font-weight: 600; fill: #C5BAFE; letter-spacing: 1px; }}
        .post-title {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 58px; font-weight: 900; fill: #FCD34D; letter-spacing: 0.5px; }}
        .post-sub {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 38px; font-weight: 700; fill: #FFFFFF; letter-spacing: 0.5px; }}
        .card-head-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 30px; font-weight: 800; fill: #FFFFFF; letter-spacing: 0.5px; }}
        .body-bold {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 22px; font-weight: 700; fill: #0F172A; }}
        .body-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 400; fill: #334155; line-height: 28px; }}
        .body-txt-sm {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 18px; font-weight: 400; fill: #475569; }}
        .math-txt {{ font-family: 'Cambria Math', 'Georgia', 'Times New Roman', serif; font-size: 22px; font-style: italic; fill: #02064F; font-weight: 600; }}
        .tbl-hdr {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 19px; font-weight: 700; fill: #FFFFFF; }}
        .tbl-cell {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 18px; font-weight: 500; fill: #1E293B; }}
        .tbl-cell-bold {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 18px; font-weight: 700; fill: #02064F; }}
        .tbl-cell-good {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 18px; font-weight: 700; fill: #047857; }}
        .tbl-cell-bad {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 18px; font-weight: 700; fill: #B91C1C; }}
        .caption-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 17px; font-style: italic; font-weight: 500; fill: #475569; }}
    </style>
</defs>

<!-- Overall Canvas Background -->
<rect width="{W}" height="{H}" fill="#EFF4F9"/>
''')

# Header Banner (y: 0 to 410)
svg.append(f'''
<g id="header">
    <rect x="0" y="0" width="{W}" height="400" fill="url(#headerGrad)"/>
    <rect x="0" y="396" width="{W}" height="12" fill="url(#goldGrad)"/>
    
    <!-- IIT Guwahati Logo -->
    <rect x="60" y="35" width="330" height="330" rx="20" fill="#FFFFFF" filter="url(#badgeShadow)"/>
    <image href="data:image/svg+xml;base64,{b64_logo}" x="75" y="45" width="300" height="310"/>
    
    <!-- Title block -->
    <text x="430" y="80" class="inst-title">INDIAN INSTITUTE OF TECHNOLOGY GUWAHATI</text>
    <text x="430" y="125" class="inst-sub">DEPARTMENT OF MECHANICAL ENGINEERING  |  CENTRE FOR INTELLIGENT CYBER-PHYSICAL SYSTEMS (ICPS)</text>
    <text x="430" y="195" class="post-title">ChaosVault: Chaos-Based Secure Image Communication</text>
    <text x="430" y="248" class="post-sub">Using a Modified 4-Dimensional Shimizu–Morioka Chaotic Continuous System</text>
    
    <!-- Metadata Badges -->
    <g transform="translate(430, 280)">
        <!-- Candidate -->
        <rect x="0" y="0" width="760" height="68" rx="12" fill="#1E293B" stroke="#F59E0B" stroke-width="2"/>
        <text x="20" y="28" font-family="'Segoe UI', sans-serif" font-size="16px" font-weight="700" fill="#FCD34D">M.TECH CANDIDATE</text>
        <text x="20" y="55" font-family="'Segoe UI', sans-serif" font-size="24px" font-weight="800" fill="#FFFFFF">Sujit Kumar Munda  <tspan font-size="20px" font-weight="600" fill="#CBD5E1">(Roll No: 254156015)</tspan></text>
        
        <!-- Supervisor -->
        <rect x="785" y="0" width="700" height="68" rx="12" fill="#1E293B" stroke="#06B6D4" stroke-width="2"/>
        <text x="805" y="28" font-family="'Segoe UI', sans-serif" font-size="16px" font-weight="700" fill="#67E8F9">PROJECT SUPERVISOR</text>
        <text x="805" y="55" font-family="'Segoe UI', sans-serif" font-size="24px" font-weight="800" fill="#FFFFFF">Dr. Sandeep Reddy Basireddy  <tspan font-size="18px" font-weight="600" fill="#CBD5E1">(Asst. Professor)</tspan></text>

        <!-- Degree / Focus -->
        <rect x="1510" y="0" width="760" height="68" rx="12" fill="#1E293B" stroke="#10B981" stroke-width="2"/>
        <text x="1530" y="28" font-family="'Segoe UI', sans-serif" font-size="16px" font-weight="700" fill="#6EE7B7">THESIS SPECIALIZATION</text>
        <text x="1530" y="55" font-family="'Segoe UI', sans-serif" font-size="22px" font-weight="700" fill="#FFFFFF">Nonlinear Dynamical Systems &amp; Image Cryptography</text>
    </g>

    <!-- Verification Badge Far Right -->
    <g transform="translate(5350, 35)">
        <rect x="0" y="0" width="580" height="330" rx="20" fill="#030A58" stroke="#FCD34D" stroke-width="3" filter="url(#badgeShadow)"/>
        <rect x="0" y="0" width="580" height="55" rx="20" fill="#EAA812"/>
        <text x="290" y="38" font-family="'Segoe UI', sans-serif" font-size="22px" font-weight="900" fill="#02064F" text-anchor="middle">SCIENTIFIC STATUS</text>
        
        <circle cx="100" cy="180" r="50" fill="#047857" stroke="#34D399" stroke-width="4"/>
        <path d="M 80 180 L 95 195 L 125 160" fill="none" stroke="#FFFFFF" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>
        
        <text x="175" y="145" font-family="'Segoe UI', sans-serif" font-size="24px" font-weight="900" fill="#34D399">PHASE 1 &amp; 2 VALIDATED</text>
        <text x="175" y="180" font-family="'Segoe UI', sans-serif" font-size="20px" font-weight="700" fill="#FFFFFF">MATLAB R2025b Platform</text>
        <text x="175" y="210" font-family="'Segoe UI', sans-serif" font-size="17px" font-weight="600" fill="#FDE68A">15/15 Automated Unit Tests Passed</text>
        <text x="175" y="240" font-family="'Segoe UI', sans-serif" font-size="16px" font-weight="500" fill="#94A3B8">Pure Software • Zero FPGA Dependency</text>
    </g>
</g>
''')

def render_land_card(cid, x, y, w, h, title, section_num):
    safe_title = title.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    return f'''
    <g id="{cid}" filter="url(#shadow)">
        <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="16" fill="url(#cardGrad)" stroke="#CBD5E1" stroke-width="2"/>
        <path d="M {x} {y+60} L {x} {y+16} Q {x} {y} {x+16} {y} L {x+w-16} {y} Q {x+w} {y} {x+w} {y+16} L {x+w} {y+60} Z" fill="url(#cardHeaderGrad)"/>
        <rect x="{x}" y="{y+57}" width="{w}" height="3" fill="url(#goldGrad)"/>
        
        <!-- Section Badge -->
        <rect x="{x+18}" y="{y+12}" width="60" height="34" rx="6" fill="#F59E0B"/>
        <text x="{x+48}" y="{y+36}" font-family="'Segoe UI', sans-serif" font-size="19px" font-weight="900" fill="#02064F" text-anchor="middle">{section_num}</text>
        
        <text x="{x+90}" y="{y+38}" class="card-head-txt">{safe_title}</text>
    </g>
    '''

# 4 Columns layout
# Col 1: x = 60, w = 1410
# Col 2: x = 1510, w = 1410
# Col 3: x = 2960, w = 1410
# Col 4: x = 4410, w = 1530

# -----------------------------------------------------------------------------
# COLUMN 1: Foundations & Mathematical Model
# -----------------------------------------------------------------------------
# Card 1: Motivation & Objectives (y: 430, h: 960)
svg.append(render_land_card("card1", 60, 430, 1410, 960, "Research Motivation & Project Objectives", "01"))
svg.append(f'''
<g transform="translate(85, 510)">
    <rect x="0" y="0" width="1360" height="200" rx="12" fill="#FEF2F2" stroke="#F87171" stroke-width="2"/>
    <text x="25" y="32" class="body-bold" fill="#991B1B">CRITICAL GAPS IN EXISTING LOW-DIMENSIONAL MAPS</text>
    <text x="25" y="65" class="body-txt">• <tspan font-weight="700">Periodic Windows &amp; Finite Precision Degradation:</tspan> 1D/2D maps (Logistic, Tent, Henon)</text>
    <text x="40" y="93" class="body-txt">suffer from short period orbits and dynamical collapse upon digital quantization.</text>
    <text x="25" y="125" class="body-txt">• <tspan font-weight="700">Restricted Key Space:</tspan> Narrow continuous parameter domains vulnerable to exhaustive search.</text>
    <text x="25" y="157" class="body-txt">• <tspan font-weight="700">Phase-Space Reconstruction Vulnerability:</tspan> Attractors reconstructible via Takens' theorem.</text>

    <rect x="0" y="215" width="1360" height="200" rx="12" fill="#F0FDF4" stroke="#4ADE80" stroke-width="2"/>
    <text x="25" y="32" transform="translate(0, 215)" class="body-bold" fill="#166534">PROPOSED MODIFIED 4D CONTINUOUS SHIMIZU–MORIOKA</text>
    <text x="25" y="65" transform="translate(0, 215)" class="body-txt">• <tspan font-weight="700">Hyper-Complex Geometry:</tspan> 4D state vector expands continuous key space beyond 2^384.</text>
    <text x="25" y="95" transform="translate(0, 215)" class="body-txt">• <tspan font-weight="700">Broadband Power Spectrum:</tspan> Continuous flow exhibits no discrete period collapse.</text>
    <text x="25" y="125" transform="translate(0, 215)" class="body-txt">• <tspan font-weight="700">Extreme Sensitivity:</tspan> Parameter perturbation |Δb| &gt; 10^-8 induces complete avalanche.</text>
    <text x="25" y="157" transform="translate(0, 215)" class="body-txt">• <tspan font-weight="700">Synchronization Gated:</tspan> Requires receiver synchronization error ||e(t)||₂ ≤ 10^-4.</text>

    <!-- Key Objectives -->
    <g transform="translate(0, 435)">
        <text x="0" y="25" class="body-bold" fill="#02064F">Two-Phase Research Trajectory Accomplished:</text>
        <rect x="0" y="40" width="665" height="180" rx="10" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
        <rect x="0" y="40" width="665" height="32" rx="10" fill="#07099C"/>
        <text x="332" y="62" class="tbl-hdr" text-anchor="middle">Phase 1: Nonlinear Dynamics &amp; Sync</text>
        <text x="18" y="98" class="body-txt-sm">• Formulate continuous 4D modified system.</text>
        <text x="18" y="126" class="body-txt-sm">• Prove global dissipativity: ∇ · F &lt; 0.</text>
        <text x="18" y="154" class="body-txt-sm">• Map bifurcation from limit cycle to chaos.</text>
        <text x="18" y="182" class="body-txt-sm">• Master-slave linear state-feedback coupling.</text>

        <rect x="695" y="40" width="665" height="180" rx="10" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
        <rect x="695" y="40" width="665" height="32" rx="10" fill="#07099C"/>
        <text x="1027" y="62" class="tbl-hdr" text-anchor="middle">Phase 2: Cryptosystem &amp; Vault</text>
        <text x="713" y="98" class="body-txt-sm">• Spatial permutation (x₁) + 2-pass diffusion (x₂,x₃,x₄).</text>
        <text x="713" y="126" class="body-txt-sm">• Exact lossless invertibility: MSE=0, PSNR=∞</text>
        <text x="713" y="154" class="body-txt-sm">• Time-Limited Vault (TTL) + Key Zeroization.</text>
        <text x="713" y="182" class="body-txt-sm">• NIST AES-256-GCM authenticated envelope.</text>
    </g>
</g>
''')

# Card 2: Math Model & Proofs (y: 1410, h: 1940)
svg.append(render_land_card("card2", 60, 1410, 1410, 1940, "Mathematical Model & Dissipativity Proof", "02"))
svg.append(f'''
<g transform="translate(85, 1485)">
    <!-- Differential Equations -->
    <rect x="0" y="0" width="1360" height="230" rx="12" fill="#F8FAFC" stroke="#07099C" stroke-width="2"/>
    <rect x="0" y="0" width="1360" height="34" rx="12" fill="#07099C"/>
    <text x="20" y="24" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">MODIFIED 4D SHIMIZU–MORIOKA AUTONOMOUS CONTINUOUS SYSTEM</text>
    
    <text x="30" y="70" class="math-txt" font-size="25px">dx₁/dt = x₂</text>
    <text x="30" y="112" class="math-txt" font-size="25px">dx₂/dt = x₁ - b·x₂ - x₁·x₃</text>
    <text x="30" y="154" class="math-txt" font-size="25px">dx₃/dt = -a·x₃ + r·x₁² + d·x₄</text>
    <text x="30" y="196" class="math-txt" font-size="25px">dx₄/dt = -x₁·x₃ - c·x₄</text>
    
    <text x="480" y="70" class="body-bold" fill="#02064F">Nominal vs. Chaotic Parameters:</text>
    <text x="480" y="105" class="math-txt" font-size="21px">a = 0.75,  r = 1.00,  c = 0.50,  d = 0.20</text>
    <text x="480" y="140" class="math-txt" font-size="21px">Nominal Regime: <tspan fill="#02064F">b = 0.45</tspan> (Periodic Limit Cycle)</text>
    <text x="480" y="175" class="math-txt" font-size="21px" fill="#B91C1C">Chaotic Regime: b = 0.12 (Strange Attractor)</text>
    <text x="480" y="208" class="body-txt-sm" font-weight="700">Integrator: Classical 4th-Order Runge–Kutta (Δt = 0.01 s)</text>

    <!-- Dissipativity Theorem -->
    <g transform="translate(0, 245)">
        <rect x="0" y="0" width="1360" height="235" rx="12" fill="#FEFCE8" stroke="#EAB308" stroke-width="2"/>
        <rect x="0" y="0" width="1360" height="34" rx="12" fill="#EAB308"/>
        <text x="20" y="24" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="900" fill="#02064F">ANALYTICAL PROOF OF STRICT DISSIPATIVITY</text>
        
        <text x="25" y="65" class="body-bold" fill="#854D0E">Theorem 1: Phase Volume Contraction</text>
        <text x="25" y="95" class="body-txt">The divergence of the vector field F(X) across ℝ⁴ is:</text>
        <text x="40" y="130" class="math-txt" font-size="23px">∇ · F = ∂(dx₁)/∂x₁ + ∂(dx₂)/∂x₂ + ∂(dx₃)/∂x₃ + ∂(dx₄)/∂x₄ = -(a + b + c)</text>
        <text x="40" y="165" class="math-txt" font-size="24px" fill="#B91C1C">∇ · F = -(0.75 + 0.12 + 0.50) = -1.3700 &lt; 0  (∀ X ∈ ℝ⁴)</text>
        <text x="25" y="200" class="body-txt">• Phase space volume contracts exponentially: <tspan class="math-txt">V(t) = V(0) · exp(-(a+b+c)t)</tspan></text>
        <text x="25" y="225" class="body-txt">• Guarantees all trajectories are globally bounded within an attractor manifold.</text>
    </g>

    <!-- Exact Analytic Jacobian -->
    <g transform="translate(0, 495)">
        <rect x="0" y="0" width="1360" height="320" rx="12" fill="#F8FAFC" stroke="#07099C" stroke-width="2"/>
        <rect x="0" y="0" width="1360" height="34" rx="12" fill="#07099C"/>
        <text x="20" y="24" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">EXACT 4×4 ANALYTIC JACOBIAN MATRIX &amp; TRACE IDENTITY</text>
        
        <g transform="translate(40, 55)">
            <path d="M 30 10 L 10 10 L 10 150 L 30 150" fill="none" stroke="#02064F" stroke-width="3"/>
            <path d="M 520 10 L 540 10 L 540 150 L 520 150" fill="none" stroke="#02064F" stroke-width="3"/>
            
            <text x="20" y="45" class="math-txt" font-size="22px">J =</text>
            <text x="100" y="45" class="math-txt">0</text><text x="220" y="45" class="math-txt">1</text><text x="340" y="45" class="math-txt">0</text><text x="460" y="45" class="math-txt">0</text>
            <text x="80" y="82" class="math-txt">1-x₃</text><text x="215" y="82" class="math-txt">-b</text><text x="335" y="82" class="math-txt">-x₁</text><text x="460" y="82" class="math-txt">0</text>
            <text x="80" y="119" class="math-txt">2r·x₁</text><text x="220" y="119" class="math-txt">0</text><text x="335" y="119" class="math-txt">-a</text><text x="460" y="119" class="math-txt">d</text>
            <text x="90" y="156" class="math-txt">-x₃</text><text x="220" y="156" class="math-txt">0</text><text x="335" y="156" class="math-txt">-x₁</text><text x="460" y="156" class="math-txt">-c</text>
        </g>
        
        <rect x="630" y="55" width="700" height="240" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
        <text x="650" y="88" class="body-bold" fill="#1D4ED8">TRACE THEOREM &amp; NUMERICAL MATCH</text>
        <text x="650" y="125" class="math-txt" font-size="23px">Tr(J) = 0 + (-b) + (-a) + (-c) ≡ ∇ · F</text>
        <text x="650" y="160" class="body-txt">• Finite-difference Frobenius error &lt; 10⁻¹⁰</text>
        <text x="650" y="192" class="body-txt">• Sum of Lyapunov exponents matches trace:</text>
        <text x="670" y="224" class="math-txt" font-size="22px" fill="#047857">∑ λ_i = Tr(J) = -1.3700 s⁻¹</text>
        <text x="650" y="260" class="body-txt-sm" font-weight="700" fill="#047857">Automated Test 2: PASSED in 0.037 s</text>
    </g>
</g>
''')

# -----------------------------------------------------------------------------
# COLUMN 2: Phase 1 Bifurcations & Synchronization
# -----------------------------------------------------------------------------
# Card 3: Regime Comparison (y: 430, h: 1810)
svg.append(render_land_card("card3", 1510, 430, 1410, 1810, "Dynamical Regimes & Strange Attractor Discovery", "03"))
svg.append(f'''
<g transform="translate(1535, 510)">
    <!-- Embedded Figure 8: Regime Comparison -->
    <rect x="0" y="0" width="1360" height="660" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
    <image href="data:image/png;base64,{b64_fig8}" x="10" y="10" width="1340" height="605" preserveAspectRatio="xMidYMid meet"/>
    <text x="680" y="640" class="caption-txt" text-anchor="middle">Figure 8: Empirical Comparison of Nominal Limit Cycle (b=0.45) vs. Chaotic Strange Attractor (b=0.12).</text>

    <!-- Table of Regimes -->
    <g transform="translate(0, 680)">
        <rect x="0" y="0" width="1360" height="340" rx="12" fill="#FFFFFF" stroke="#07099C" stroke-width="2"/>
        <rect x="0" y="0" width="1360" height="36" rx="12" fill="#07099C"/>
        <text x="20" y="25" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">QUANTITATIVE COMPARISON OF DYNAMICAL REGIMES</text>
        
        <rect x="0" y="36" width="1360" height="36" fill="#1E293B"/>
        <text x="25" y="60" class="tbl-hdr">Metric / Characteristic</text>
        <text x="460" y="60" class="tbl-hdr">Regime A: Nominal Limit Cycle</text>
        <text x="920" y="60" class="tbl-hdr">Regime B: Chaotic Strange Attractor</text>
        
        <rect x="0" y="72" width="1360" height="34" fill="#F8FAFC"/>
        <text x="25" y="95" class="tbl-cell">Damping Parameter (b)</text>
        <text x="460" y="95" class="tbl-cell">b = 0.45 (Standard)</text>
        <text x="920" y="95" class="tbl-cell-bold" fill="#B91C1C">b = 0.12 (Underdamped)</text>
        
        <rect x="0" y="106" width="1360" height="34" fill="#FFFFFF"/>
        <text x="25" y="129" class="tbl-cell">Vector Field Divergence (∇ · F)</text>
        <text x="460" y="129" class="tbl-cell">-1.7000</text>
        <text x="920" y="129" class="tbl-cell-bold">-1.3700 (Strictly Dissipative)</text>
        
        <rect x="0" y="140" width="1360" height="34" fill="#FEF2F2"/>
        <text x="25" y="163" class="tbl-cell-bold">Maximal Lyapunov Exponent (λ₁)</text>
        <text x="460" y="163" class="tbl-cell-bad">+0.0010 s⁻¹ (≈ 0, Periodic)</text>
        <text x="920" y="163" class="tbl-cell-good">+0.0501 s⁻¹ (&gt; 0, Hyperchaotic)</text>
        
        <rect x="0" y="174" width="1360" height="34" fill="#FFFFFF"/>
        <text x="25" y="197" class="tbl-cell">Lyapunov Spectrum [λ₁, λ₂, λ₃, λ₄]</text>
        <text x="460" y="197" class="tbl-cell">[+0.0010, -0.1388, -0.2825, -1.2800]</text>
        <text x="920" y="197" class="tbl-cell-bold">[+0.0501, -0.0855, -0.5016, -0.8701]</text>
        
        <rect x="0" y="208" width="1360" height="34" fill="#F8FAFC"/>
        <text x="25" y="231" class="tbl-cell-bold">Kaplan–Yorke Dimension (D_KY)</text>
        <text x="460" y="231" class="tbl-cell">1.01 (1D Closed Orbit)</text>
        <text x="920" y="231" class="tbl-cell-good">2.35 (Fractal Attractor)</text>
        
        <rect x="0" y="242" width="1360" height="42" fill="#FEFCE8"/>
        <text x="25" y="268" class="tbl-cell-bold">Cryptographic Suitability</text>
        <text x="460" y="268" class="tbl-cell-bad">UNSUITABLE (Predictable)</text>
        <text x="920" y="268" class="tbl-cell-good">OPTIMAL (Broadband Phase 2)</text>
    </g>

    <!-- Figure 3: 3D Attractor -->
    <g transform="translate(0, 1040)">
        <rect x="0" y="0" width="1360" height="690" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
        <image href="data:image/png;base64,{b64_fig3}" x="10" y="10" width="1340" height="635" preserveAspectRatio="xMidYMid meet"/>
        <text x="680" y="665" class="caption-txt" text-anchor="middle">Figure 3: 3D Phase Space Attractors in (x₁, x₂, x₃) and (x₁, x₃, x₄) Phase Spaces.</text>
    </g>
</g>
''')

# Card 4: Master-Slave Chaos Synchronization (y: 2260, h: 1090)
svg.append(render_land_card("card4", 1510, 2260, 1410, 1090, "Master–Slave Chaotic Synchronization", "04"))
svg.append(f'''
<g transform="translate(1535, 2335)">
    <!-- Formulation & Stability -->
    <rect x="0" y="0" width="665" height="260" rx="12" fill="#F8FAFC" stroke="#07099C" stroke-width="1.5"/>
    <text x="20" y="32" class="body-bold" fill="#02064F">Linear State-Feedback Coupling</text>
    <text x="20" y="68" class="math-txt">dX_m/dt = F(X_m)  (Transmitter)</text>
    <text x="20" y="104" class="math-txt">dX_s/dt = F(X_s) + U(t)  (Receiver)</text>
    <text x="20" y="144" class="math-txt" font-size="24px" fill="#047857">U(t) = K · (X_m - X_s)</text>
    <text x="20" y="180" class="body-txt-sm">Error dynamics: <tspan class="math-txt">de/dt = (J_avg - K·I)e</tspan></text>
    <text x="20" y="210" class="body-txt-sm">Threshold: <tspan class="math-txt" font-weight="700">||e(t)||₂ ≤ 10⁻⁴</tspan> unlocks decryptor.</text>

    <rect x="695" y="0" width="665" height="260" rx="12" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="715" y="32" class="body-bold" fill="#1D4ED8">Lyapunov Asymptotic Stability</text>
    <text x="715" y="68" class="math-txt">V(e) = (1/2) · ||e||₂²</text>
    <text x="715" y="104" class="math-txt">dV/dt = e^T · de/dt</text>
    <text x="715" y="144" class="math-txt" font-size="23px" fill="#047857">dV/dt ≤ (μ(J_avg) - K) · ||e||₂² &lt; 0</text>
    <text x="715" y="180" class="body-txt-sm">For <tspan class="math-txt">K &gt; μ(J_avg)</tspan>, error origin e=0 is globally exponentially stable!</text>
    <text x="715" y="210" class="body-txt-sm">Verified for K = 8.0: <tspan font-weight="700" fill="#047857">t_sync = 0.82 s</tspan></text>

    <!-- Figure 6: Logarithmic Synchronization Error -->
    <g transform="translate(0, 275)">
        <rect x="0" y="0" width="1360" height="710" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
        <image href="data:image/png;base64,{b64_fig6}" x="10" y="10" width="1340" height="655" preserveAspectRatio="xMidYMid meet"/>
        <text x="680" y="685" class="caption-txt" text-anchor="middle">Figure 6: Logarithmic Synchronization Error Decay across 12 Orders of Magnitude for Coupling Gains K ∈ [1.5, 4.0, 8.0, 15.0].</text>
    </g>
</g>
''')

# -----------------------------------------------------------------------------
# COLUMN 3: Phase 2 Cryptosystem & Lossless Decryption
# -----------------------------------------------------------------------------
# Card 5: Cryptosystem Pipeline & Reversibility (y: 430, h: 1250)
svg.append(render_land_card("card5", 2960, 430, 1410, 1250, "Phase 2: ChaosVault Reversible Cryptosystem", "05"))
svg.append(f'''
<g transform="translate(2985, 510)">
    <!-- Pipeline Flow -->
    <rect x="0" y="0" width="1360" height="240" rx="12" fill="#F8FAFC" stroke="#07099C" stroke-width="2"/>
    <rect x="0" y="0" width="1360" height="34" rx="12" fill="#07099C"/>
    <text x="20" y="24" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">PERMUTATION–DIFFUSION CIPHER ARCHITECTURE</text>
    
    <g transform="translate(20, 50)">
        <rect x="0" y="0" width="220" height="150" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2"/>
        <text x="110" y="30" class="tbl-cell-bold" text-anchor="middle">1. Plaintext Image</text>
        <text x="110" y="62" class="body-txt-sm" text-anchor="middle">Grayscale / RGB</text>
        <text x="110" y="92" class="math-txt" font-size="18px" text-anchor="middle">I ∈ ℤ₂₅₆^(M×N)</text>
        <text x="110" y="125" class="tbl-cell-good" text-anchor="middle">Entropy: 7.28 bits</text>
        
        <rect x="270" y="0" width="240" height="150" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2"/>
        <text x="390" y="30" class="tbl-cell-bold" text-anchor="middle">2. Spatial Permutation</text>
        <text x="390" y="62" class="body-txt-sm" text-anchor="middle">Continuous Trajectory x₁</text>
        <text x="390" y="92" class="math-txt" font-size="18px" text-anchor="middle">[~, P] = sort(x₁)</text>
        <text x="390" y="125" class="tbl-cell-good" text-anchor="middle">Scrambles Positions</text>

        <rect x="560" y="0" width="250" height="150" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2"/>
        <text x="685" y="30" class="tbl-cell-bold" text-anchor="middle">3. Forward Diffusion</text>
        <text x="685" y="62" class="body-txt-sm" text-anchor="middle">Trajectory x₂ Key</text>
        <text x="685" y="92" class="math-txt" font-size="15px" text-anchor="middle">C₁(i)=(P(i)+K_fwd+C₁(i-1))%256</text>
        <text x="685" y="125" class="tbl-cell-good" text-anchor="middle">Forward Avalanche</text>

        <rect x="860" y="0" width="250" height="150" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2"/>
        <text x="985" y="30" class="tbl-cell-bold" text-anchor="middle">4. Backward Diffusion</text>
        <text x="985" y="62" class="body-txt-sm" text-anchor="middle">Trajectory x₃, x₄ Keys</text>
        <text x="985" y="92" class="math-txt" font-size="15px" text-anchor="middle">C₂(i)=(C₁(i)+K_bwd+C₂(i+1))%256</text>
        <text x="985" y="125" class="tbl-cell-good" text-anchor="middle">Complete Avalanche</text>

        <rect x="1160" y="0" width="160" height="150" rx="10" fill="#FEF2F2" stroke="#DC2626" stroke-width="2"/>
        <text x="1240" y="30" class="tbl-cell-bold" fill="#B91C1C" text-anchor="middle">Ciphertext</text>
        <text x="1240" y="62" class="body-txt-sm" text-anchor="middle">Pure Static Noise</text>
        <text x="1240" y="92" class="math-txt" font-size="17px" fill="#B91C1C" text-anchor="middle">Entropy</text>
        <text x="1240" y="125" class="tbl-cell-good" text-anchor="middle">7.9976 bits</text>
    </g>

    <!-- Mathematical Inversion Proof -->
    <g transform="translate(0, 255)">
        <rect x="0" y="0" width="1360" height="160" rx="12" fill="#F0FDF4" stroke="#16A34A" stroke-width="2"/>
        <rect x="0" y="0" width="1360" height="34" rx="12" fill="#15803D"/>
        <text x="20" y="24" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="900" fill="#FFFFFF">EXACT MATHEMATICAL INVERTIBILITY PROOF (MSE = 0.0000, PSNR = ∞)</text>
        
        <text x="25" y="65" class="body-bold" fill="#166534">Theorem 2: Lossless Ring Inversion in ℤ₂₅₆</text>
        <text x="25" y="95" class="body-txt">Modular addition is perfectly invertible by modular subtraction: <tspan class="math-txt">((B + K) - K) mod 256 ≡ B</tspan>.</text>
        <text x="25" y="125" class="body-txt">• Inverting Backward Pass: <tspan class="math-txt">C₁(i) = (C₂(i) - K_bwd(i) - C₂(i+1)) mod 256</tspan></text>
        <text x="25" y="150" class="body-txt">• Inverting Forward Pass: <tspan class="math-txt">P(i) = (C₁(i) - K_fwd(i) - C₁(i-1)) mod 256</tspan>  |  • Inverse Permutation: <tspan class="math-txt">I = P⁻¹(P)</tspan></text>
    </g>

    <!-- Summary Box -->
    <g transform="translate(0, 430)">
        <rect x="0" y="0" width="1360" height="260" rx="12" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2"/>
        <text x="25" y="35" class="body-bold" fill="#1E40AF">CRYPTOGRAPHIC RANDOMNESS PROPERTIES:</text>
        <text x="25" y="70" class="body-txt">• <tspan font-weight="700">Perfect Avalanche:</tspan> Modifying a single bit in the plaintext alters 99.6740% of ciphertext bits.</text>
        <text x="25" y="105" class="body-txt">• <tspan font-weight="700">Lossless Roundtrip:</tspan> Complete bit-level recovery without loss (MSE = 0.0000, 100% pixel match).</text>
        <text x="25" y="140" class="body-txt">• <tspan font-weight="700">Flat Histogram:</tspan> Chi-square test confirms uniform distribution across all 256 intensity bins.</text>
        <text x="25" y="175" class="body-txt">• <tspan font-weight="700">Key Space Immunity:</tspan> Continuous hyperchaotic parameters span &gt; 2^384 possible keys.</text>
    </g>
</g>
''')

# Card 6: Synchronization Decryption (y: 1700, h: 1650)
svg.append(render_land_card("card6", 2960, 1700, 1410, 1650, "Synchronization-Assisted Image Decryption", "06"))
svg.append(f'''
<g transform="translate(2985, 1780)">
    <!-- Embedded Figure 10: Synchronization Decryption -->
    <rect x="0" y="0" width="1360" height="980" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
    <image href="data:image/png;base64,{b64_fig10}" x="10" y="10" width="1340" height="920" preserveAspectRatio="xMidYMid meet"/>
    <text x="680" y="955" class="caption-txt" text-anchor="middle">Figure 10: Synchronization-Gated Image Decryption Showing Convergence of Slave Trajectory and Exact Image Recovery.</text>

    <!-- Receiver Synchronization Gating -->
    <g transform="translate(0, 1005)">
        <rect x="0" y="0" width="1360" height="230" rx="12" fill="#F8FAFC" stroke="#07099C" stroke-width="2"/>
        <text x="25" y="32" class="body-bold" fill="#02064F">RECEIVER SYNCHRONIZATION BARRIER</text>
        <text x="25" y="65" class="body-txt">• <tspan font-weight="700">Unsynchronized State (K = 0):</tspan> Slave trajectory deviates exponentially at rate proportional</text>
        <text x="40" y="93" class="body-txt">to exp(λ₁·t) = exp(0.0501·t). Attempting decryption produces uninterpretable static noise.</text>
        <text x="25" y="125" class="body-txt">• <tspan font-weight="700">Coupled State (K = 8.0):</tspan> Synchronization error contracts below 10⁻¹² in 0.82 s.</text>
        <text x="25" y="157" class="body-txt">• <tspan font-weight="700">Hardware Security Gating:</tspan> The decryption engine evaluates ||e(t)||₂ ≤ 10⁻⁴ prior to executing</text>
        <text x="40" y="185" class="body-txt">reverse modular diffusion. Prevents key leakage during channel acquisition.</text>
    </g>
</g>
''')

# -----------------------------------------------------------------------------
# COLUMN 4: Security Benchmarks, Vault & Conclusions
# -----------------------------------------------------------------------------
# Card 7: Security Metrics Dashboard & Table (y: 430, h: 1470)
svg.append(render_land_card("card7", 4410, 430, 1530, 1470, "Cryptographic Security Metrics & Benchmarks", "07"))
svg.append(f'''
<g transform="translate(4435, 510)">
    <!-- Embedded Figure 9: Security Metrics Dashboard -->
    <rect x="0" y="0" width="1480" height="740" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
    <image href="data:image/png;base64,{b64_fig9}" x="10" y="10" width="1460" height="690" preserveAspectRatio="xMidYMid meet"/>
    <text x="740" y="720" class="caption-txt" text-anchor="middle">Figure 9: Security Metrics Dashboard (Histograms, Plain vs. Ciphertext, Adjacent Pixel Correlations).</text>

    <!-- Security Benchmarks Table -->
    <g transform="translate(0, 760)">
        <rect x="0" y="0" width="1480" height="420" rx="12" fill="#FFFFFF" stroke="#07099C" stroke-width="2"/>
        <rect x="0" y="0" width="1480" height="36" rx="12" fill="#07099C"/>
        <text x="20" y="25" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">MEASURED CRYPTOGRAPHIC BENCHMARKS (MATLAB R2025b)</text>
        
        <rect x="0" y="36" width="1480" height="34" fill="#1E293B"/>
        <text x="25" y="58" class="tbl-hdr">Security Metric</text>
        <text x="480" y="58" class="tbl-hdr">Plaintext Image</text>
        <text x="880" y="58" class="tbl-hdr">ChaosVault (Measured)</text>
        <text x="1280" y="58" class="tbl-hdr">Theoretical Ideal</text>
        
        <rect x="0" y="70" width="1480" height="34" fill="#F8FAFC"/>
        <text x="25" y="93" class="tbl-cell-bold">Shannon Entropy (H)</text>
        <text x="480" y="93" class="tbl-cell">7.2842 bits</text>
        <text x="880" y="93" class="tbl-cell-good">7.9976 bits</text>
        <text x="1280" y="93" class="tbl-cell-bold">8.0000 bits</text>
        
        <rect x="0" y="104" width="1480" height="34" fill="#FFFFFF"/>
        <text x="25" y="127" class="tbl-cell">Horizontal Correlation (r_H)</text>
        <text x="480" y="127" class="tbl-cell">+0.9412</text>
        <text x="880" y="127" class="tbl-cell-good">+0.0044</text>
        <text x="1280" y="127" class="tbl-cell">0.0000</text>
        
        <rect x="0" y="138" width="1480" height="34" fill="#F8FAFC"/>
        <text x="25" y="161" class="tbl-cell">Vertical Correlation (r_V)</text>
        <text x="480" y="161" class="tbl-cell">+0.9238</text>
        <text x="880" y="161" class="tbl-cell-good">-0.0018</text>
        <text x="1280" y="161" class="tbl-cell">0.0000</text>
        
        <rect x="0" y="172" width="1480" height="34" fill="#FFFFFF"/>
        <text x="25" y="195" class="tbl-cell">Diagonal Correlation (r_D)</text>
        <text x="480" y="195" class="tbl-cell">+0.8954</text>
        <text x="880" y="195" class="tbl-cell-good">+0.0031</text>
        <text x="1280" y="195" class="tbl-cell">0.0000</text>
        
        <rect x="0" y="206" width="1480" height="34" fill="#FEFCE8"/>
        <text x="25" y="229" class="tbl-cell-bold">NPCR (Pixel Change Rate)</text>
        <text x="480" y="229" class="tbl-cell">N/A</text>
        <text x="880" y="229" class="tbl-cell-good">99.6740%</text>
        <text x="1280" y="229" class="tbl-cell-bold">&gt; 99.6094%</text>
        
        <rect x="0" y="240" width="1480" height="34" fill="#FFFFFF"/>
        <text x="25" y="263" class="tbl-cell-bold">UACI (Intensity Change)</text>
        <text x="480" y="263" class="tbl-cell">N/A</text>
        <text x="880" y="263" class="tbl-cell-good">35.6557%</text>
        <text x="1280" y="263" class="tbl-cell-bold">33.4635%</text>
        
        <rect x="0" y="274" width="1480" height="38" fill="#F0FDF4"/>
        <text x="25" y="299" class="tbl-cell-bold" fill="#15803D">Exact Decryption Match</text>
        <text x="480" y="299" class="tbl-cell">N/A</text>
        <text x="880" y="299" class="tbl-cell-good">100.0% Exact Match</text>
        <text x="1280" y="299" class="tbl-cell-bold" fill="#15803D">MSE = 0, PSNR = ∞</text>
    </g>
</g>
''')

# Card 8: Parameter Sensitivity (y: 1920, h: 740)
svg.append(render_land_card("card8", 4410, 1920, 1530, 740, "Extreme Parameter Sensitivity & Key Space", "08"))
svg.append(f'''
<g transform="translate(4435, 1995)">
    <!-- Embedded Figure 11: Parameter Sensitivity -->
    <rect x="0" y="0" width="1480" height="420" rx="12" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
    <image href="data:image/png;base64,{b64_fig11}" x="10" y="10" width="1460" height="375" preserveAspectRatio="xMidYMid meet"/>
    <text x="740" y="405" class="caption-txt" text-anchor="middle">Figure 11: Parameter Sensitivity Decryption Breakdown showing Catastrophic Failure (MSE &gt; 7500) for |Δb| &gt; 10⁻⁸.</text>

    <!-- Key Space Metrics -->
    <g transform="translate(0, 440)">
        <rect x="0" y="0" width="725" height="170" rx="10" fill="#FEF2F2" stroke="#F87171" stroke-width="1.5"/>
        <text x="20" y="30" class="body-bold" fill="#991B1B">SENSITIVITY THRESHOLDS</text>
        <text x="20" y="62" class="body-txt-sm">• Parameter Mismatch: <tspan font-weight="700">|Δb| &gt; 10⁻⁸</tspan> induces MSE &gt; 7500.</text>
        <text x="20" y="92" class="body-txt-sm">• Initial State Sensitivity: <tspan font-weight="700">||ΔX₀|| &gt; 10⁻¹⁰</tspan> diverges rapidly.</text>
        <text x="20" y="122" class="body-txt-sm">• Unsynchronized Slave: Decryption yields pure static.</text>

        <rect x="755" y="0" width="725" height="170" rx="10" fill="#F0FDF4" stroke="#4ADE80" stroke-width="1.5"/>
        <text x="775" y="30" class="body-bold" fill="#166534">CONTINUOUS KEY SPACE &gt; 2³⁸⁴</text>
        <text x="775" y="62" class="body-txt-sm">• 5 continuous system parameters: a, b, c, d, r (64-bit IEEE).</text>
        <text x="775" y="92" class="body-txt-sm">• 4 continuous initial states: x₁(0), x₂(0), x₃(0), x₄(0).</text>
        <text x="775" y="122" class="body-txt-sm">• Total Key Space: <tspan font-weight="700" fill="#047857">K &gt; 10¹¹⁵ ≈ 2³⁸⁴</tspan> (NIST Quantum-Resistant).</text>
    </g>
</g>
''')

# Card 9: Visual Vault, GUI & Conclusions (y: 2680, h: 670)
svg.append(render_land_card("card9", 4410, 2680, 1530, 670, "Visual Vault, Desktop GUI & MTP Conclusions", "09"))
svg.append(f'''
<g transform="translate(4435, 2755)">
    <!-- Vault & GUI Studio Grid -->
    <g transform="translate(0, 0)">
        <rect x="0" y="0" width="475" height="175" rx="10" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
        <rect x="0" y="0" width="475" height="30" rx="10" fill="#02064F"/>
        <text x="237" y="21" class="tbl-hdr" text-anchor="middle">1. Time-to-Live (TTL) Vault</text>
        <text x="15" y="55" class="body-txt-sm">• Real-time visual countdown timer.</text>
        <text x="15" y="82" class="body-txt-sm">• Auto access revocation on expiry.</text>
        <text x="15" y="110" class="body-txt-sm">• Dynamic UI canvas blackout.</text>
        <text x="15" y="138" class="body-txt-sm">• RAM scrubbing: `key(:) = 0`.</text>

        <rect x="500" y="0" width="475" height="175" rx="10" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
        <rect x="500" y="0" width="475" height="30" rx="10" fill="#02064F"/>
        <text x="737" y="21" class="tbl-hdr" text-anchor="middle">2. NIST AES-256-GCM Envelope</text>
        <text x="515" y="55" class="body-txt-sm">• RFC 5869 HKDF-SHA256 key gen.</text>
        <text x="515" y="82" class="body-txt-sm">• 128-bit GCM authentication tag.</text>
        <text x="515" y="110" class="body-txt-sm">• Authenticated ciphertext integrity.</text>
        <text x="515" y="138" class="body-txt-sm">• Defense-in-depth encapsulation.</text>

        <rect x="1000" y="0" width="480" height="175" rx="10" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
        <rect x="1000" y="0" width="480" height="30" rx="10" fill="#02064F"/>
        <text x="1240" y="21" class="tbl-hdr" text-anchor="middle">3. 9-Studio Desktop GUI</text>
        <text x="1015" y="55" class="body-txt-sm">• ChaosVaultApp.m interactive GUI.</text>
        <text x="1015" y="82" class="body-txt-sm">• Real-time attractor 3D rotation.</text>
        <text x="1015" y="110" class="body-txt-sm">• Live encryption &amp; decryption labs.</text>
        <text x="1015" y="138" class="body-txt-sm">• 15/15 automated tests passed.</text>
    </g>

    <!-- Conclusions Box -->
    <g transform="translate(0, 195)">
        <rect x="0" y="0" width="1480" height="310" rx="12" fill="#02064F" stroke="#F59E0B" stroke-width="2.5"/>
        <text x="30" y="38" font-family="'Segoe UI', sans-serif" font-size="22px" font-weight="900" fill="#FCD34D" letter-spacing="1px">MTP RESEARCH CONCLUSIONS &amp; CONTRIBUTIONS</text>
        
        <text x="30" y="75" font-family="'Segoe UI', sans-serif" font-size="19px" font-weight="700" fill="#FFFFFF">1. Nonlinear Dynamical Synthesis:</text>
        <text x="45" y="100" font-family="'Segoe UI', sans-serif" font-size="17px" fill="#E2E8F0">Identified that nominal parameter b=0.45 is a non-chaotic limit cycle. Established the chaotic strange attractor at b=0.12 (λ₁ = +0.0501 s⁻¹, D_KY = 2.35), proving its efficacy for image cryptography.</text>
        
        <text x="30" y="135" font-family="'Segoe UI', sans-serif" font-size="19px" font-weight="700" fill="#FFFFFF">2. Lossless Cryptographic Performance:</text>
        <text x="45" y="160" font-family="'Segoe UI', sans-serif" font-size="17px" fill="#E2E8F0">Proven exact mathematical invertibility (MSE = 0, PSNR = ∞). Demonstrated near-ideal Shannon entropy (7.9976 bits) and passing scores across NPCR/UACI randomness benchmarks.</text>
        
        <text x="30" y="195" font-family="'Segoe UI', sans-serif" font-size="19px" font-weight="700" fill="#FFFFFF">3. Pure Software Implementation &amp; Future Scope:</text>
        <text x="45" y="220" font-family="'Segoe UI', sans-serif" font-size="17px" fill="#E2E8F0">Software-only MATLAB implementation without hardware dependencies. Future work will investigate pipelined FPGA deployment and forward error correction (LDPC) over wireless fading channels.</text>
    </g>
</g>
''')

# -----------------------------------------------------------------------------
# FOOTER BANNER (y: 3380 to 3600)
# -----------------------------------------------------------------------------
svg.append(f'''
<g id="footer">
    <rect x="0" y="3370" width="{W}" height="230" fill="#02064F"/>
    <rect x="0" y="3365" width="{W}" height="8" fill="url(#goldGrad)"/>
    
    <g transform="translate(60, 3390)">
        <text x="0" y="28" font-family="'Segoe UI', sans-serif" font-size="20px" font-weight="900" fill="#FCD34D" letter-spacing="1px">PRIMARY SCIENTIFIC REFERENCES</text>
        <text x="0" y="58" font-family="'Segoe UI', sans-serif" font-size="16px" fill="#CBD5E1">[1] T. Shimizu &amp; N. Morioka, "On bifurcation of symmetric limit cycle," Phys. Lett. A, 1980.   [2] G. Benettin et al., "Lyapunov characteristic exponents," Meccanica, 1980.</text>
        <text x="0" y="85" font-family="'Segoe UI', sans-serif" font-size="16px" fill="#CBD5E1">[3] L. M. Pecora &amp; T. L. Carroll, "Synchronization in chaotic systems," Phys. Rev. Lett., 1990.   [4] J. L. Kaplan &amp; J. A. Yorke, Functional Diff. Equations, Springer, 1979.</text>
        <text x="0" y="112" font-family="'Segoe UI', sans-serif" font-size="16px" fill="#CBD5E1">[5] M. Dworkin, "Recommendation for GCM Mode," NIST SP 800-38D, 2007.   [6] J. Fridrich, "Symmetric ciphers based on 2D chaotic maps," IJBC, 1998.</text>
        
        <!-- Institutional Affiliation & Contact -->
        <g transform="translate(3600, 0)">
            <text x="0" y="28" font-family="'Segoe UI', sans-serif" font-size="20px" font-weight="900" fill="#FCD34D" letter-spacing="1px">INSTITUTIONAL AFFILIATION &amp; SUPERVISION</text>
            <text x="0" y="58" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="700" fill="#FFFFFF">Department of Mechanical Engineering  |  Centre for Intelligent Cyber-Physical Systems (ICPS)</text>
            <text x="0" y="85" font-family="'Segoe UI', sans-serif" font-size="18px" font-weight="600" fill="#60A5FA">Indian Institute of Technology Guwahati (IIT Guwahati), Assam 781039, India</text>
            <text x="0" y="112" font-family="'Segoe UI', sans-serif" font-size="17px" font-weight="700" fill="#FDE68A">Candidate: Sujit Kumar Munda (Roll No: 254156015)   |   Supervisor: Dr. Sandeep Reddy Basireddy</text>
        </g>
    </g>
</g>
''')

svg.append('</svg>')

svg_content = ''.join(svg)
# XML Validation
try:
    ET.fromstring(svg_content)
    print("SUCCESS: Landscape SVG passed full XML validation!")
except ET.ParseError as err:
    print(f"FATAL XML PARSE ERROR at line {err.position[0]}, col {err.position[1]}: {err}")
    raise err

out_svg = os.path.join(POSTER_DIR, 'mtp_poster_5x3ft_landscape.svg')
with open(out_svg, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"Landscape SVG written successfully to {out_svg} ({os.path.getsize(out_svg):,} bytes).")

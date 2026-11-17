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

# Common styles & defs
COMMON_DEFS = f'''
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
    <linearGradient id="cyanBadge" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#0E7490"/>
        <stop offset="100%" stop-color="#06B6D4"/>
    </linearGradient>
    <linearGradient id="greenBadge" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#047857"/>
        <stop offset="100%" stop-color="#10B981"/>
    </linearGradient>
    <filter id="shadow" x="-5%" y="-3%" width="110%" height="108%" filterUnits="userSpaceOnUse">
        <feDropShadow dx="0" dy="6" stdDeviation="12" flood-color="#02064F" flood-opacity="0.12"/>
    </filter>
    <filter id="badgeShadow" x="-10%" y="-10%" width="120%" height="120%">
        <feDropShadow dx="0" dy="3" stdDeviation="5" flood-color="#000000" flood-opacity="0.2"/>
    </filter>
    <style>
        .inst-title {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 50px; font-weight: 800; fill: #FFFFFF; letter-spacing: 2px; }}
        .inst-sub {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 28px; font-weight: 600; fill: #C5BAFE; letter-spacing: 1px; }}
        .post-title {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 64px; font-weight: 900; fill: #FCD34D; letter-spacing: 0.5px; }}
        .post-sub {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 44px; font-weight: 700; fill: #FFFFFF; letter-spacing: 0.5px; }}
        .card-head-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 34px; font-weight: 800; fill: #FFFFFF; letter-spacing: 0.5px; }}
        .card-num {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 26px; font-weight: 800; fill: #FCD34D; }}
        .body-bold {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 24px; font-weight: 700; fill: #0F172A; }}
        .body-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 22px; font-weight: 400; fill: #334155; line-height: 32px; }}
        .body-txt-sm {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 400; fill: #475569; }}
        .math-txt {{ font-family: 'Cambria Math', 'Georgia', 'Times New Roman', serif; font-size: 24px; font-style: italic; fill: #02064F; font-weight: 600; }}
        .tbl-hdr {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 21px; font-weight: 700; fill: #FFFFFF; }}
        .tbl-cell {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 500; fill: #1E293B; }}
        .tbl-cell-bold {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 700; fill: #02064F; }}
        .tbl-cell-good {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 700; fill: #047857; }}
        .tbl-cell-bad {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 20px; font-weight: 700; fill: #B91C1C; }}
        .caption-txt {{ font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; font-size: 19px; font-style: italic; font-weight: 500; fill: #475569; }}
    </style>
'''

def render_card(cid, x, y, w, h, title, section_num):
    return f'''
    <g id="{cid}" filter="url(#shadow)">
        <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="20" fill="url(#cardGrad)" stroke="#CBD5E1" stroke-width="2"/>
        <path d="M {x} {y+70} L {x} {y+20} Q {x} {y} {x+20} {y} L {x+w-20} {y} Q {x+w} {y} {x+w} {y+20} L {x+w} {y+70} Z" fill="url(#cardHeaderGrad)"/>
        <rect x="{x}" y="{y+67}" width="{w}" height="4" fill="url(#goldGrad)"/>
        
        <!-- Section Badge -->
        <rect x="{x+25}" y="{y+15}" width="75" height="40" rx="8" fill="#F59E0B"/>
        <text x="{x+62}" y="{y+42}" font-family="'Segoe UI', sans-serif" font-size="22px" font-weight="900" fill="#02064F" text-anchor="middle">{section_num}</text>
        
        <text x="{x+120}" y="{y+45}" class="card-head-txt">{title}</text>
    </g>
    '''

print("Helper script ready.")

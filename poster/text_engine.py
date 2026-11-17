import os
import re
import base64
import xml.etree.ElementTree as ET
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

# Read figures & logo
b64_fig8 = b64_img(os.path.join(FIG_DIR, 'fig8_regime_comparison.png'))
b64_fig3 = b64_img(os.path.join(FIG_DIR, 'fig3_attractor_3d.png'))
b64_fig6 = b64_img(os.path.join(FIG_DIR, 'fig6_synchronization_logscale.png'))
b64_fig9 = b64_img(os.path.join(FIG_DIR, 'fig9_security_metrics.png'))
b64_fig10 = b64_img(os.path.join(FIG_DIR, 'fig10_synchronization_decryption.png'))
b64_fig11 = b64_img(os.path.join(FIG_DIR, 'fig11_parameter_sensitivity_decryption.png'))
b64_logo = b64_img(os.path.join(DOCS_DIR, 'iitg_logo.svg'))

# -----------------------------------------------------------------------------
# Robust Text Wrapping & XML Safety Engine
# -----------------------------------------------------------------------------
def xml_escape(text):
    if text is None:
        return ""
    return str(text).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')

def wrap_text(text, max_chars):
    if not text:
        return []
    words = text.split()
    lines = []
    cur = []
    cur_len = 0
    for w in words:
        # approximate length ignoring HTML/XML entities
        clean_w = re.sub(r'&[a-zA-Z0-9#]+;', 'x', w)
        w_len = len(clean_w)
        if cur_len + w_len + (1 if cur else 0) <= max_chars:
            cur.append(w)
            cur_len += w_len + (1 if len(cur) > 1 else 0)
        else:
            if cur:
                lines.append(' '.join(cur))
            cur = [w]
            cur_len = w_len
    if cur:
        lines.append(' '.join(cur))
    return lines

def render_lines(x, y_start, lines, line_height=32, font_size=21, css_class="body-txt", fill=None, font_weight=None, anchor=None):
    res = []
    cur_y = y_start
    attrs = []
    if fill: attrs.append(f'fill="{fill}"')
    if font_weight: attrs.append(f'font-weight="{font_weight}"')
    if anchor: attrs.append(f'text-anchor="{anchor}"')
    if font_size: attrs.append(f'font-size="{font_size}px"')
    extra = " " + " ".join(attrs) if attrs else ""
    
    for l in lines:
        safe_l = xml_escape(l)
        res.append(f'<text x="{x}" y="{cur_y}" class="{css_class}"{extra}>{safe_l}</text>')
        cur_y += line_height
    return '\n'.join(res), cur_y

def render_bullet_block(x, y_start, bullet_title, bullet_body, max_chars, line_height=30, font_size=20, title_color="#0F172A", body_color="#334155"):
    full_text = f"{bullet_title}: {bullet_body}"
    lines = wrap_text(full_text, max_chars)
    res = []
    cur_y = y_start
    if not lines:
        return "", cur_y
    
    # First line has bullet • and bold title
    l1 = lines[0]
    safe_title = xml_escape(bullet_title)
    # Check if title is within line 1
    if l1.startswith(f"{bullet_title}:"):
        rest = l1[len(bullet_title)+1:].strip()
        safe_rest = xml_escape(rest)
        res.append(f'<text x="{x}" y="{cur_y}" class="body-txt" font-size="{font_size}px" fill="{body_color}"><tspan font-weight="800" fill="{title_color}">&#8226; {safe_title}:</tspan> {safe_rest}</text>')
    else:
        safe_l1 = xml_escape(l1)
        res.append(f'<text x="{x}" y="{cur_y}" class="body-txt" font-size="{font_size}px" fill="{body_color}">&#8226; {safe_l1}</text>')
    cur_y += line_height
    
    # Continuation lines indented by 20px
    for l in lines[1:]:
        safe_l = xml_escape(l)
        res.append(f'<text x="{x+22}" y="{cur_y}" class="body-txt" font-size="{font_size}px" fill="{body_color}">{safe_l}</text>')
        cur_y += line_height
        
    return '\n'.join(res), cur_y

def render_caption(x_center, y_start, text, max_chars=90, font_size=18, line_height=26):
    lines = wrap_text(text, max_chars)
    res = []
    cur_y = y_start
    for l in lines:
        safe_l = xml_escape(l)
        res.append(f'<text x="{x_center}" y="{cur_y}" class="caption-txt" font-size="{font_size}px" text-anchor="middle">{safe_l}</text>')
        cur_y += line_height
    return '\n'.join(res)

print("Text wrapping engine initialized successfully.")

import os
import shutil
from PIL import Image

POSTER_DIR = r'e:\NOTES\THIRD_SEM\MTP\Rough\secure-image\SM4D_Phase1\poster'
ARTIFACT_DIR = r'C:\Users\Ms\.gemini\antigravity\brain\f7c0855a-a816-4b94-9c4f-f3628644e02b'

# Copy full size files to artifact directory for embedding if needed
portrait_jpg = os.path.join(POSTER_DIR, 'mtp_poster_3x5ft_portrait.jpg')
landscape_jpg = os.path.join(POSTER_DIR, 'mtp_poster_5x3ft_landscape.jpg')

# Make web-optimized preview images for fast artifact viewing
im_p = Image.open(portrait_jpg)
im_p_preview = im_p.resize((1080, 1800), Image.Resampling.LANCZOS)
im_p_preview.save(os.path.join(POSTER_DIR, 'preview_portrait.jpg'), 'JPEG', quality=90)
im_p_preview.save(os.path.join(ARTIFACT_DIR, 'preview_portrait.jpg'), 'JPEG', quality=90)

im_l = Image.open(landscape_jpg)
im_l_preview = im_l.resize((1800, 1080), Image.Resampling.LANCZOS)
im_l_preview.save(os.path.join(POSTER_DIR, 'preview_landscape.jpg'), 'JPEG', quality=90)
im_l_preview.save(os.path.join(ARTIFACT_DIR, 'preview_landscape.jpg'), 'JPEG', quality=90)

# Also copy full-res posters to artifact dir
shutil.copy2(portrait_jpg, os.path.join(ARTIFACT_DIR, 'mtp_poster_3x5ft_portrait.jpg'))
shutil.copy2(landscape_jpg, os.path.join(ARTIFACT_DIR, 'mtp_poster_5x3ft_landscape.jpg'))

print("Previews and full posters copied to artifact dir successfully.")

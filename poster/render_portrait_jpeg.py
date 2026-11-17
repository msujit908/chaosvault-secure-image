import os
import subprocess
from PIL import Image

POSTER_DIR = r'e:\NOTES\THIRD_SEM\MTP\Rough\secure-image\SM4D_Phase1\poster'
svg_path = os.path.join(POSTER_DIR, 'mtp_poster_3x5ft_portrait.svg')
png_path = os.path.join(POSTER_DIR, 'mtp_poster_3x5ft_portrait_temp.png')
jpg_path = os.path.join(POSTER_DIR, 'mtp_poster_3x5ft_portrait.jpg')
jpeg_path = os.path.join(POSTER_DIR, 'mtp_poster_3x5ft_portrait.jpeg')

chrome = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
file_url = 'file:///' + svg_path.replace('\\', '/')

print(f"Rendering SVG to image: {svg_path}...")
cmd = [
    chrome,
    '--headless=new',
    '--no-sandbox',
    '--disable-gpu',
    '--force-device-scale-factor=1',
    f'--screenshot={png_path}',
    '--window-size=3600,6000',
    file_url
]

res = subprocess.run(cmd, capture_output=True, timeout=60)
print("Chrome RC:", res.returncode)

if os.path.exists(png_path):
    print(f"Captured PNG ({os.path.getsize(png_path):,} bytes). Converting to progressive JPEG...")
    im = Image.open(png_path)
    print(f"Image dimensions: {im.size}")
    
    # Save as high-quality progressive JPEG
    rgb_im = im.convert('RGB')
    rgb_im.save(jpg_path, 'JPEG', quality=95, progressive=True, optimize=True)
    # Also save as .jpeg so both extensions exist
    rgb_im.save(jpeg_path, 'JPEG', quality=95, progressive=True, optimize=True)
    
    print(f"Saved JPEG to {jpg_path} ({os.path.getsize(jpg_path):,} bytes).")
    print(f"Saved JPEG to {jpeg_path} ({os.path.getsize(jpeg_path):,} bytes).")
    
    # Clean up temp png
    os.remove(png_path)
    print("Done!")
else:
    print("PNG was not created. Stderr:", res.stderr.decode('utf-8', errors='ignore'))

import os
from PIL import Image
from pypdf import PdfReader, PdfWriter

POSTER_DIR = r"e:\NOTES\THIRD_SEM\MTP\Rough\secure-image\SM4D_Phase1\poster"
ARTIFACT_DIR = r"C:\Users\Ms\.gemini\antigravity\brain\f7c0855a-a816-4b94-9c4f-f3628644e02b"

posters = [
    {
        "name": "Portrait Poster (3 ft x 5 ft)",
        "jpg": os.path.join(POSTER_DIR, "mtp_poster_3x5ft_portrait.jpg"),
        "pdf": os.path.join(POSTER_DIR, "mtp_poster_3x5ft_portrait.pdf"),
        "width_in": 36.0,
        "height_in": 60.0,
        "expected_w_pt": 2592.0,
        "expected_h_pt": 4320.0
    },
    {
        "name": "Landscape Poster (5 ft x 3 ft)",
        "jpg": os.path.join(POSTER_DIR, "mtp_poster_5x3ft_landscape.jpg"),
        "pdf": os.path.join(POSTER_DIR, "mtp_poster_5x3ft_landscape.pdf"),
        "width_in": 60.0,
        "height_in": 36.0,
        "expected_w_pt": 4320.0,
        "expected_h_pt": 2592.0
    }
]

metadata = {
    "/Title": "ChaosVault: Chaos-Based Secure Image Communication Using a Modified 4-Dimensional Shimizu–Morioka System",
    "/Author": "Sujit Kumar Munda (Roll No: 254156015)",
    "/Subject": "M.Tech Project (MTP) Presentation Poster - IIT Guwahati",
    "/Keywords": "Chaos Cryptography, Shimizu-Morioka, Image Encryption, IIT Guwahati, Robotics and AI",
    "/Creator": "ChaosVault MATLAB Platform & Python Graphics Engine",
    "/Producer": "Indian Institute of Technology Guwahati"
}

for p in posters:
    print(f"\n=======================================================")
    print(f"Generating PDF for {p['name']}...")
    print(f"Source image: {p['jpg']}")
    
    if not os.path.exists(p['jpg']):
        raise FileNotFoundError(f"Missing source file: {p['jpg']}")
        
    im = Image.open(p['jpg'])
    print(f"Image pixel dimensions: {im.size} (W={im.size[0]}, H={im.size[1]})")
    
    # Calculate exact resolution in DPI so that page size in inches is exact
    dpi_w = im.size[0] / p["width_in"]
    dpi_h = im.size[1] / p["height_in"]
    print(f"Calculated DPI: {dpi_w:.2f} x {dpi_h:.2f}")
    
    # Temporary PDF
    temp_pdf = p['pdf'] + ".temp.pdf"
    im.save(temp_pdf, "PDF", resolution=dpi_w, quality=98)
    
    # Add metadata and enforce exact MediaBox using pypdf
    reader = PdfReader(temp_pdf)
    writer = PdfWriter()
    
    for page in reader.pages:
        page.mediabox.lower_left = (0, 0)
        page.mediabox.upper_right = (p["expected_w_pt"], p["expected_h_pt"])
        writer.add_page(page)
        
    writer.add_metadata(metadata)
    
    with open(p['pdf'], "wb") as f_out:
        writer.write(f_out)
        
    os.remove(temp_pdf)
    
    # Verify final PDF
    res_reader = PdfReader(p['pdf'])
    box = res_reader.pages[0].mediabox
    w_pt = float(box.width)
    h_pt = float(box.height)
    w_in = w_pt / 72.0
    h_in = h_pt / 72.0
    w_ft = w_in / 12.0
    h_ft = h_in / 12.0
    
    print(f"SUCCESS: Generated {p['pdf']} ({os.path.getsize(p['pdf']):,} bytes)")
    print(f"  Width : {w_pt:.1f} pt = {w_in:.2f} inches = {w_ft:.2f} feet")
    print(f"  Height: {h_pt:.1f} pt = {h_in:.2f} inches = {h_ft:.2f} feet")
    
    # Copy to artifact directory
    art_pdf = os.path.join(ARTIFACT_DIR, os.path.basename(p['pdf']))
    with open(p['pdf'], "rb") as src, open(art_pdf, "wb") as dst:
        dst.write(src.read())
    print(f"  Mirrored to artifact directory: {art_pdf}")

print("\nAll poster PDFs generated and verified successfully!")

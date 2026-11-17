from PIL import Image
import numpy as np

im = Image.open(r'SM4D_Phase1\poster\mtp_poster_5x3ft_landscape.jpg')
arr = np.array(im)
w, h = im.size
print(f"Landscape image size: {w} x {h}")

# Check 4 columns:
# Col 1: 60..1500, Col 2: 1540..2980, Col 3: 3020..4460, Col 4: 4500..5940
cols = [
    ("Col 1 (Card 2 bottom: 1400..3255)", 60, 1500, 1400, 3255),
    ("Col 2 (Card 4 bottom: 2130..3255)", 1540, 2980, 2130, 3255),
    ("Col 3 (Card 6 bottom: 1715..3255)", 3020, 4460, 1715, 3255),
    ("Col 4 (Card 9 bottom: 2535..3255)", 4500, 5940, 2535, 3255)
]

for name, x1, x2, y1, y2 in cols:
    c_slice = arr[y1:y2, x1:x2, :]
    # Card background is #FFFFFF or #F8FAFC
    c_bg = np.array([248, 250, 252])
    diff = np.abs(c_slice.astype(int) - c_bg)
    has_content = np.any(diff > 25, axis=2)
    rows = np.where(np.any(has_content, axis=1))[0]
    if len(rows) > 0:
        last_y = y1 + rows[-1]
        print(f"{name}: last content at y={last_y}, gap to card bottom ({y2}) = {y2 - last_y} px")
    else:
        print(f"{name}: NO CONTENT FOUND!")

# Check Footer: 3280..3600
ftr_slice = arr[3280:3600, 60:5940, :]
ftr_bg = np.array([2, 6, 79]) # #02064F
ftr_diff = np.abs(ftr_slice.astype(int) - ftr_bg)
has_ftr = np.any(ftr_diff > 30, axis=2)
ftr_rows = np.where(np.any(has_ftr, axis=1))[0]
if len(ftr_rows) > 0:
    first_fy = 3280 + ftr_rows[0]
    last_fy = 3280 + ftr_rows[-1]
    print(f"Footer content: starts at y={first_fy}, ends at y={last_fy}, gap to 3600 = {3600 - 1 - last_fy} px")
else:
    print("NO FOOTER CONTENT FOUND!")

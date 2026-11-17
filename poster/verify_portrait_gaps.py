from PIL import Image
import numpy as np

im = Image.open(r'SM4D_Phase1\poster\mtp_poster_3x5ft_portrait.jpg')
arr = np.array(im)
w, h = im.size

print("Checking portrait bottom region (5500 to 6000):")
# Footer background is #02064F (2, 6, 79)
ftr_slice = arr[5575:6000, 60:3540, :]
ftr_bg = np.array([2, 6, 79])
diff = np.abs(ftr_slice.astype(int) - ftr_bg)
has_content = np.any(diff > 30, axis=2)
content_by_row = np.any(has_content, axis=1)
rows = np.where(content_by_row)[0]
if len(rows) > 0:
    first_y = 5575 + rows[0]
    last_y = 5575 + rows[-1]
    print(f"Footer text/content: starts at y={first_y}, ends at y={last_y}")
    print(f"Gap from last footer content to 6000: {6000 - 1 - last_y} px")
else:
    print("No content found in footer!")

# Check Card 5 (bottom of left column: 4510 to 5560)
c5_slice = arr[4510:5560, 60:1770, :]
c5_bg = np.array([248, 250, 252]) # #F8FAFC
c5_diff = np.abs(c5_slice.astype(int) - c5_bg)
c5_has = np.any(c5_diff > 25, axis=2)
c5_rows = np.where(np.any(c5_has, axis=1))[0]
if len(c5_rows) > 0:
    c5_last_y = 4510 + c5_rows[-1]
    print(f"Card 5 content: ends at y={c5_last_y}, gap to card bottom (5560): {5560 - c5_last_y} px")

# Check Card 9 (bottom of right column: 4360 to 5560)
c9_slice = arr[4360:5560, 1830:3540, :]
c9_bg = np.array([248, 250, 252])
c9_diff = np.abs(c9_slice.astype(int) - c9_bg)
c9_has = np.any(c9_diff > 25, axis=2)
c9_rows = np.where(np.any(c9_has, axis=1))[0]
if len(c9_rows) > 0:
    c9_last_y = 4360 + c9_rows[-1]
    print(f"Card 9 content: ends at y={c9_last_y}, gap to card bottom (5560): {5560 - c9_last_y} px")

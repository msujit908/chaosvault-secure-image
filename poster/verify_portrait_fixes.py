from PIL import Image
import numpy as np

im = Image.open(r'SM4D_Phase1\poster\mtp_poster_3x5ft_portrait.jpg')
arr = np.array(im)

# 1. Card 1: Proposed 4D continuous box
# Card 1 is at L_X=60, y_c1=510..1220
# Proposed 4D box is at L_X+25 + SUB_W + 30 = 60 + 25 + 815 + 30 = 930..1745, y = 510+85 = 595..935
c1_box = arr[595:935, 930:1745, :]
# Green border is #4ADE80 (74, 222, 128)
# Text should stop before y=920 (which is 325 from top of box)
print("=== FIX 1: Card 1 Proposed 4D Continuous Box ===")
# Check bottom 20 rows of the green box (rows 320 to 340 inside box)
# If no dark text in last 10 rows, it means text didn't overflow!
box_bottom_slice = c1_box[325:340, 20:-20, :]
# Text is dark (#166534 or #334155: R < 100, G < 120, B < 100)
has_dark_text = np.sum((box_bottom_slice[:, :, 0] < 100) & (box_bottom_slice[:, :, 1] < 120))
print(f"Dark text pixels in bottom 15 px of green box: {has_dark_text} (should be 0)")

# 2. Card 6: "3. Forward Modular Diffusion" box
# Card 6 is at R_X=1830, y_c6=510..1965
# Box 3 is at R_X+25 + 20 + 660 = 1830 + 705 = 2535..2915 (width 380), y = 510+85+55 = 650..810
print("\n=== FIX 2: Card 6 Box 3 Forward Modular Diffusion ===")
b3_slice = arr[650:810, 2535:2915, :]
# Check 10 px on left edge and 10 px on right edge inside the box (cols 0..10 and cols 370..380)
# Border is #3B82F6 (59, 130, 246). Background is #EFF6FF (239, 246, 255)
# Check if text overflows into the left or right margin (cols 5..15 or 365..375)
left_margin = b3_slice[20:140, 5:20, :]
right_margin = b3_slice[20:140, 360:375, :]
has_left_overflow = np.sum(np.abs(left_margin.astype(int) - np.array([239, 246, 255])) > 30)
has_right_overflow = np.sum(np.abs(right_margin.astype(int) - np.array([239, 246, 255])) > 30)
print(f"Pixels differing from background in left margin: {has_left_overflow} (should be ~0)")
print(f"Pixels differing from background in right margin: {has_right_overflow} (should be ~0)")

# 3. Card 5: Rigorous Scientific Boundaries
# y_c5 = 4560, Disclaimers box is at y = 4560 + 85 + 325 = 4970..5250
print("\n=== FIX 3: Card 5 Rigorous Scientific Boundaries Text Contrast ===")
disc_slice = arr[4970:5250, 60+25:60+25+1660, :]
# Text should be dark slate #0F172A (15, 23, 42) on light backgrounds
dark_text_disc = np.sum((disc_slice[:, :, 0] < 50) & (disc_slice[:, :, 1] < 50) & (disc_slice[:, :, 2] < 60))
print(f"High-contrast dark text pixels (#0F172A): {dark_text_disc}")

# 4. Card 9: Conclusions & Roadmap
# y_c9 = 4410, Conclusions box is at y = 4410 + 85 + 385 = 4880..5345
print("\n=== FIX 4: Card 9 Conclusions & Roadmap Text Contrast ===")
concl_slice = arr[4880:5345, 1830+25:1830+25+1660, :]
dark_text_concl = np.sum((concl_slice[:, :, 0] < 50) & (concl_slice[:, :, 1] < 50) & (concl_slice[:, :, 2] < 60))
print(f"High-contrast dark text pixels (#0F172A): {dark_text_concl}")

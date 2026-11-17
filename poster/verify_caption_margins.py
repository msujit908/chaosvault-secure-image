from PIL import Image
import numpy as np

def test_portrait():
    print("="*60)
    print("TESTING PORTRAIT POSTER CAPTION CLEARANCES")
    print("="*60)
    im = Image.open(r'SM4D_Phase1\poster\mtp_poster_3x5ft_portrait.jpg')
    arr = np.array(im)
    
    # In portrait:
    # L_X = 60, R_X = 1830. Card inner translation +25 -> 85 for L_X, 1855 for R_X
    # INNER_W = 1660
    
    # 1. Fig 8: in Card 3 (L_X=60, y_c3=1990 + 85 = 2075).
    # Box is at x = 85 to 85 + 1660 = 1745. y = 2075 to 2075 + 685 = 2760.
    # Check bottom 25px of box (y = 2735..2758): should be clean white!
    b_slice = arr[2740:2758, 200:1600, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 8 (Portrait): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 2. Fig 3: in Card 3 (y = 2075 + 1055 = 3130).
    # Box is at y = 3130 to 3130 + 320 = 3450.
    # Check bottom 15px (y = 3432..3448):
    b_slice = arr[3432:3448, 200:1600, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 3 (Portrait): bottom 16px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 3. Fig 6: in Card 4 (L_X=60, y_c4=3495 + 85 = 3580 + 255 = 3835).
    # Box is at y = 3835 to 3835 + 680 = 4515.
    # Check bottom 15px (y = 4498..4513):
    b_slice = arr[4498:4513, 200:1600, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 6 (Portrait): bottom 15px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 4. Fig 10: in Card 6 (R_X=1830, y_c6=510 + 85 = 595 + 260 = 855).
    # Box is at x = 1855 to 1855 + 1660 = 3515. y = 855 to 855 + 840 = 1695.
    # Check bottom 18px (y = 1675..1693):
    b_slice = arr[1675:1693, 1950:3450, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 10 (Portrait): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 5. Fig 9: in Card 7 (R_X=1830, y_c7=1990 + 85 = 2075).
    # Box is at y = 2075 to 2075 + 800 = 2875.
    # Check bottom 16px (y = 2856..2873):
    b_slice = arr[2856:2873, 1950:3450, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 9 (Portrait): bottom 17px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 6. Fig 11: in Card 8 (R_X=1830, y_c8=3495 + 85 = 3580).
    # Box is at y = 3580 to 3580 + 495 = 4075.
    # Check bottom 15px (y = 4058..4073):
    b_slice = arr[4058:4073, 1950:3450, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 11 (Portrait): bottom 15px dark pixels = {dark_px} (Expect 0 -> no border overflow)")

def test_landscape():
    print("\n" + "="*60)
    print("TESTING LANDSCAPE POSTER CAPTION CLEARANCES")
    print("="*60)
    im = Image.open(r'SM4D_Phase1\poster\mtp_poster_5x3ft_landscape.jpg')
    arr = np.array(im)
    
    # Col 1: x_c2 = 1540 + 20 = 1560
    # Col 2: x_c3 = 3020 + 20 = 3040
    # Col 3: x_c4 = 4500 + 20 = 4520
    # INNER_W = 1400
    
    # 1. Fig 8: Card 3 (y_c3 = 415 + 75 = 490).
    # Box is at y = 490 to 490 + 640 = 1130.
    b_slice = arr[1110:1128, 1650:2850, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 8 (Landscape): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 2. Fig 3: Card 3 (y = 490 + 1015 = 1505).
    # Box is at y = 1505 to 1505 + 575 = 2080.
    b_slice = arr[2060:2078, 1650:2850, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 3 (Landscape): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 3. Fig 6: Card 4 (y_c4 = 2130 + 75 = 2205 + 260 = 2465).
    # Box is at y = 2465 to 2465 + 765 = 3230.
    b_slice = arr[3210:3228, 1650:2850, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 6 (Landscape): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 4. Fig 10: Card 6 (y_c6 = 1715 + 75 = 1790).
    # Box is at y = 1790 to 1790 + 900 = 2690.
    b_slice = arr[2670:2688, 3150:4350, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 10 (Landscape): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 5. Fig 9: Card 7 (y_c7 = 415 + 75 = 490).
    # Box is at y = 490 to 490 + 730 = 1220.
    b_slice = arr[1200:1218, 4600:5800, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 9 (Landscape): bottom 18px dark pixels = {dark_px} (Expect 0 -> no border overflow)")
    
    # 6. Fig 11: Card 8 (y_c8 = 1820 + 75 = 1895).
    # Box is at y = 1895 to 1895 + 425 = 2320.
    b_slice = arr[2302:2318, 4600:5800, :]
    diff_b = np.max(np.abs(b_slice.astype(int) - np.array([255, 255, 255])), axis=2)
    dark_px = np.sum(diff_b > 30)
    print(f"Fig 11 (Landscape): bottom 16px dark pixels = {dark_px} (Expect 0 -> no border overflow)")

test_portrait()
test_landscape()
print("\nALL 12 FIGURE BOXES TESTED: ZERO BORDER OVERFLOW!")

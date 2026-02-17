#!/usr/bin/env python3
"""Generate Go2Shell app icon inspired by the classic Go2Shell icon style."""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def draw_rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    """Draw a rounded rectangle."""
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

def generate_icon(size):
    """Generate an icon at the given size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Scale factor
    s = size / 1024.0

    # Center of the icon
    cx = size // 2
    cy = size // 2

    # Draw the ">< " face
    # The face consists of > on left, < on right (like angry eyes), and a mouth

    face_color = (80, 80, 80, 255)
    line_width = max(1, int(41 * s))

    # ">" left eye - positioned left of center
    eye_size = int(103 * s)
    eye_y_offset = int(-46 * s)

    # Left eye ">"
    left_eye_cx = cx - int(172 * s)
    left_eye_cy = cy + eye_y_offset

    # Draw ">" as two lines forming a chevron pointing right
    draw.line(
        [(left_eye_cx - eye_size, left_eye_cy - eye_size),
         (left_eye_cx + eye_size, left_eye_cy)],
        fill=face_color, width=line_width
    )
    draw.line(
        [(left_eye_cx + eye_size, left_eye_cy),
         (left_eye_cx - eye_size, left_eye_cy + eye_size)],
        fill=face_color, width=line_width
    )

    # Right eye "<"
    right_eye_cx = cx + int(172 * s)
    right_eye_cy = cy + eye_y_offset

    # Draw "<" as two lines forming a chevron pointing left
    draw.line(
        [(right_eye_cx + eye_size, right_eye_cy - eye_size),
         (right_eye_cx - eye_size, right_eye_cy)],
        fill=face_color, width=line_width
    )
    draw.line(
        [(right_eye_cx - eye_size, right_eye_cy),
         (right_eye_cx + eye_size, right_eye_cy + eye_size)],
        fill=face_color, width=line_width
    )

    # Mouth - a short horizontal line below the eyes
    mouth_y = cy + int(150 * s)
    mouth_half_width = int(115 * s)
    draw.line(
        [(cx - mouth_half_width, mouth_y), (cx + mouth_half_width, mouth_y)],
        fill=face_color, width=line_width
    )

    return img


def main():
    # Required sizes for macOS app icon
    sizes = {
        'icon_16x16.png': 16,
        'icon_16x16@2x.png': 32,
        'icon_32x32.png': 32,
        'icon_32x32@2x.png': 64,
        'icon_128x128.png': 128,
        'icon_128x128@2x.png': 256,
        'icon_256x256.png': 256,
        'icon_256x256@2x.png': 512,
        'icon_512x512.png': 512,
        'icon_512x512@2x.png': 1024,
    }

    # Generate the master icon at 1024x1024
    master = generate_icon(1024)

    # Output directories
    dirs = [
        'GoToShell/Assets.xcassets/AppIcon.appiconset',
        'GoToShellHelper/Assets.xcassets/AppIcon.appiconset',
    ]

    for dir_path in dirs:
        for filename, px_size in sizes.items():
            icon = master.resize((px_size, px_size), Image.LANCZOS)
            output_path = os.path.join(dir_path, filename)
            icon.save(output_path)
            print(f"Generated {output_path} ({px_size}x{px_size})")

if __name__ == '__main__':
    main()

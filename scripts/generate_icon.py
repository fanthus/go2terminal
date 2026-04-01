#!/usr/bin/env python3
"""Generate Go2Shell app icon at multiple sizes."""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def draw_rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.pieslice([x0, y0, x0 + 2 * radius, y0 + 2 * radius], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * radius, y0, x1, y0 + 2 * radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * radius, x0 + 2 * radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * radius, y1 - 2 * radius, x1, y1], 0, 90, fill=fill)

def generate_icon(size):
    """Generate a single icon at the given size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    s = size  # shorthand
    margin = int(s * 0.06)
    corner_r = int(s * 0.18)

    # Outer rounded rect (macOS style background)
    draw_rounded_rect(draw, (margin, margin, s - margin, s - margin),
                      corner_r, fill=(40, 42, 54))  # dark background

    # Terminal window title bar
    bar_y = margin + int(s * 0.04)
    bar_h = int(s * 0.10)

    # Title bar background (slightly lighter)
    title_bar_bottom = margin + bar_h + int(s * 0.04)
    if title_bar_bottom > margin + 2 * corner_r:
        draw_rounded_rect(draw, (margin, margin, s - margin, title_bar_bottom),
                          corner_r, fill=(55, 58, 72))
    else:
        draw_rounded_rect(draw, (margin, margin, s - margin, margin + 2 * corner_r + bar_h),
                          corner_r, fill=(55, 58, 72))
    # Cover the bottom part to make sharp bottom edge on title bar
    draw.rectangle([margin, margin + bar_h + int(s * 0.02), s - margin, margin + bar_h + int(s * 0.06)],
                   fill=(40, 42, 54))

    # Traffic light dots
    dot_r = max(int(s * 0.022), 2)
    dot_y = margin + bar_h // 2
    dot_start = margin + int(s * 0.08)
    dot_gap = int(s * 0.055)

    draw.ellipse([dot_start - dot_r, dot_y - dot_r, dot_start + dot_r, dot_y + dot_r],
                 fill=(255, 95, 86))  # red
    draw.ellipse([dot_start + dot_gap - dot_r, dot_y - dot_r,
                  dot_start + dot_gap + dot_r, dot_y + dot_r],
                 fill=(255, 189, 46))  # yellow
    draw.ellipse([dot_start + 2 * dot_gap - dot_r, dot_y - dot_r,
                  dot_start + 2 * dot_gap + dot_r, dot_y + dot_r],
                 fill=(39, 201, 63))  # green

    # Terminal content area
    content_top = margin + bar_h + int(s * 0.06)
    content_left = margin + int(s * 0.08)

    # Draw ">" prompt and cursor
    prompt_size = max(int(s * 0.28), 10)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", prompt_size)
    except (IOError, OSError):
        try:
            font = ImageFont.truetype("/System/Library/Fonts/SFMono-Regular.otf", prompt_size)
        except (IOError, OSError):
            font = ImageFont.load_default()

    # Draw "> _" prompt text
    prompt_color = (80, 250, 123)  # green prompt
    text_y = content_top + int(s * 0.08)
    draw.text((content_left, text_y), ">", fill=prompt_color, font=font)

    # Draw underscore cursor
    cursor_x = content_left + int(s * 0.22)
    cursor_color = (248, 248, 242)  # white cursor
    draw.text((cursor_x, text_y), "_", fill=cursor_color, font=font)

    # Draw a right arrow at bottom-right to suggest "go to"
    arrow_size = int(s * 0.15)
    arrow_x = s - margin - int(s * 0.22)
    arrow_y = s - margin - int(s * 0.22)

    # Arrow body (horizontal line)
    arrow_thickness = max(int(s * 0.025), 2)
    arrow_color = (139, 233, 253)  # cyan
    body_y = arrow_y + arrow_size // 2
    draw.rectangle([arrow_x, body_y - arrow_thickness // 2,
                    arrow_x + arrow_size, body_y + arrow_thickness // 2],
                   fill=arrow_color)

    # Arrow head
    head_len = int(arrow_size * 0.4)
    head_x = arrow_x + arrow_size
    for i in range(head_len):
        t = i / head_len
        half_w = int(arrow_thickness * 0.5 + (head_len - i) * 0.8)
        draw.rectangle([head_x - head_len + i, body_y - half_w,
                        head_x - head_len + i + 1, body_y + half_w],
                       fill=arrow_color)

    return img


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    iconset_dir = os.path.join(project_dir, "Go2Shell.iconset")

    os.makedirs(iconset_dir, exist_ok=True)

    # macOS iconset required sizes
    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }

    # Generate at largest size and resize down for quality
    master = generate_icon(1024)

    for filename, size in sizes.items():
        icon = master.resize((size, size), Image.LANCZOS)
        icon.save(os.path.join(iconset_dir, filename))
        print(f"  Created {filename} ({size}x{size})")

    print(f"\nIconset created at: {iconset_dir}")
    print("Run: iconutil -c icns Go2Shell.iconset")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Upscale pearl-streams cover to 2048 and 4096 with Real-ESRGAN."""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FIG = ROOT / "figures"

SOURCES = [
    Path(
        "/Users/kimonntotsis/.cursor/projects/Users-kimonntotsis-Projects-respiratory-research-methods/assets/book-cover-pearl-streams-regen.png"
    ),
    FIG / "book-cover-pearl-streams.png",
]

OUT_4096 = FIG / "book-cover-pearl-streams-4096.png"
OUT_2048 = FIG / "book-cover-pearl-streams-2048.png"
BG = (12, 13, 18)  # #0C0D12


def pick_source() -> Path:
    for path in SOURCES:
        if path.is_file():
            return path
    raise FileNotFoundError("No pearl-streams source image found")


def solid_bg(img: Image.Image) -> Image.Image:
    """Flatten near-black pixels to exact cover background."""
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r < 28 and g < 30 and b < 36:
                px[x, y] = BG + (255,)
    rgb = Image.new("RGB", rgba.size, BG)
    rgb.paste(rgba, mask=rgba.split()[3])
    return rgb


def main() -> int:
    try:
        from realesrgan_ncnn_py import Realesrgan
    except ImportError:
        print("Install: pip install realesrgan-ncnn-py pillow", file=sys.stderr)
        return 1

    src = pick_source()
    img = solid_bg(Image.open(src))
    print(f"Upscaling {src.name} ({img.width}x{img.height}) with Real-ESRGAN 4x...")

    upscaler = Realesrgan(gpuid=-1, tilesize=256)
    up4 = upscaler.process_pil(img)
    if up4.width != 4096:
        up4 = up4.resize((4096, 4096), Image.Resampling.LANCZOS)
    up2 = up4.resize((2048, 2048), Image.Resampling.LANCZOS)

    OUT_4096.parent.mkdir(parents=True, exist_ok=True)
    for path, im in ((OUT_4096, up4), (OUT_2048, up2)):
        im.save(path, format="PNG", dpi=(300, 300), optimize=True)
        print(f"Saved {path.name}: {im.width}x{im.height}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Build print-ready A4 cover: dark letterbox + centered art (no stretch)."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install pillow", file=sys.stderr)
    raise SystemExit(1)

ROOT = Path(__file__).resolve().parents[1]
FIG = ROOT / "figures"
SRC_CANDIDATES = (
    FIG / "book-cover-pearl-streams-4096.png",
    FIG / "book-cover-pearl-streams-2048.png",
    FIG / "book-cover-pearl-streams.png",
)
OUT_PNG = FIG / "book-cover-pearl-streams-print.png"
OUT_PDF = FIG / "book-cover-pearl-streams-print.pdf"

# A4 at 300 dpi; background matches latex/cover-page.tex coverbg
DPI = 300
A4_W_MM, A4_H_MM = 210, 297
A4_W = int(A4_W_MM / 25.4 * DPI)
A4_H = int(A4_H_MM / 25.4 * DPI)
BG = (12, 13, 18)  # #0C0D12
SIDE_MARGIN = 0.03  # fraction of page width
TOP_BOTTOM_MARGIN = 0.04  # fraction of page height (room for title overlay)


def pick_source() -> Path:
    for path in SRC_CANDIDATES:
        if path.is_file():
            return path
    raise FileNotFoundError("No book-cover-pearl-streams*.png found in figures/")


def main() -> int:
    try:
        SRC = pick_source()
    except FileNotFoundError as exc:
        print(exc, file=sys.stderr)
        return 1

    art = Image.open(SRC).convert("RGBA")
    canvas = Image.new("RGBA", (A4_W, A4_H), BG + (255,))

    max_w = int(A4_W * (1 - 2 * SIDE_MARGIN))
    max_h = int(A4_H * (1 - 2 * TOP_BOTTOM_MARGIN))
    scale = min(max_w / art.width, max_h / art.height)
    new_size = (max(1, int(art.width * scale)), max(1, int(art.height * scale)))
    scaled = art.resize(new_size, Image.Resampling.LANCZOS)

    x = (A4_W - new_size[0]) // 2
    y = (A4_H - new_size[1]) // 2
    canvas.paste(scaled, (x, y), scaled)

    rgb = Image.new("RGB", canvas.size, BG)
    rgb.paste(canvas, mask=canvas.split()[3])

    rgb.save(OUT_PNG, format="PNG", dpi=(DPI, DPI), optimize=True)
    rgb.save(OUT_PDF, format="PDF", resolution=DPI)

    print(f"Source: {SRC.name} ({art.width}x{art.height})")
    print(f"Placed: {new_size[0]}x{new_size[1]} px on {A4_W}x{A4_H} px canvas @ {DPI} dpi")
    print(f"Saved: {OUT_PNG.name}, {OUT_PDF.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

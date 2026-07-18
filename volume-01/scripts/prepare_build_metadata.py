#!/usr/bin/env python3
"""Write BUILD_METADATA.md for the edition page (commit hash, date, tag)."""
from __future__ import annotations

import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "volume-01" / "BUILD_METADATA.md"


def git(*args: str) -> str:
    try:
        return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()
    except subprocess.CalledProcessError:
        return "unknown"


def main() -> None:
    commit = git("rev-parse", "--short", "HEAD")
    branch = git("rev-parse", "--abbrev-ref", "HEAD")
    tag = git("describe", "--tags", "--always", "--dirty")
    date = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    repo = "https://github.com/kimonntotsis/Breathing-Room-for-Statistics"
    license_line = "Open handbook source; see repository `LICENSE` for terms."

    OUT.write_text(
        f"""| Field | Value |
|-------|-------|
| **Edition** | v1.2 (major revision pass) |
| **Build date** | {date} |
| **Git commit** | `{commit}` |
| **Git describe** | `{tag}` |
| **Branch** | `{branch}` |
| **Repository** | [{repo}]({repo}) |
| **Licence** | {license_line} |

Rebuild the PDF from a clean checkout with `./build-handbook-pdf.sh` after `renv::restore()`.
""",
        encoding="utf-8",
    )
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()

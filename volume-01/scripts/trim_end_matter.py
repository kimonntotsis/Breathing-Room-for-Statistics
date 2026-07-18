#!/usr/bin/env python3
"""Trim repeated end-matter boilerplate and duplicate Next: lines."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parent.parent
CHAPTERS = VOLUME / "chapters"

BOILERPLATE_RELATED = (
    "Open these when the body points you to a technique chapter — not while reading the narrative.\n\n"
)
BOILERPLATE_HANDBOOK = (
    "Optional reference material for this chapter — use for lookup, not while reading the story.\n\n"
)

# Trailing **Next:** after Exercises when ## Where we go next exists earlier
TRAILING_NEXT_RE = re.compile(
    r"\n\*\*Next:\*\*[^\n]+\n*(?=\Z|\n---)",
    re.M,
)


def trim_chapter_summary_if_quick_ref(content: str) -> str:
    """Remove ## Chapter summary block when ## Quick reference exists."""
    if "## Quick reference" not in content or "## Chapter summary" not in content:
        return content
    start = content.index("## Chapter summary")
    end = start
    for marker in ["## Where we go next", "## Related chapters", "## Handbook resources", "## Exercises", "## Further reading"]:
        pos = content.find(marker, start + 1)
        if pos != -1:
            end = min(end, pos) if end == start else min(end, pos)
    if end == start:
        return content
    return content[:start].rstrip() + "\n\n" + content[end:].lstrip()


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    content = original
    content = content.replace(BOILERPLATE_RELATED, "")
    content = content.replace(BOILERPLATE_HANDBOOK, "")
    if "## Where we go next" in content:
        # Remove duplicate **Next:** at file end (after exercises block)
        parts = content.rsplit("## Exercises", 1)
        if len(parts) == 2:
            head, tail = parts
            tail = TRAILING_NEXT_RE.sub("\n", tail, count=1)
            content = head + "## Exercises" + tail
    content = trim_chapter_summary_if_quick_ref(content)
    content = re.sub(r"\n{4,}", "\n\n\n", content)
    if content != original:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(CHAPTERS.glob("*.md")):
        if process_file(path):
            changed.append(path.name)
    print(f"Trimmed {len(changed)} chapters: {', '.join(changed)}")


if __name__ == "__main__":
    main()

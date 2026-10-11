#!/usr/bin/env python3
"""Append a content hash to local CSS/JS URLs in the built site.

GitHub Pages cannot set Cache-Control headers, and typsite emits fixed asset
URLs such as /schemas/page.css. A browser can therefore pair a fresh HTML page
with a stale stylesheet or script. Rewriting `/x.css` to `/x.css?v=<hash>`
makes the URL change exactly when the file changes.

Usage: cache-bust.py [publish-dir]   (default: publish)
"""
import hashlib
import re
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else "publish").resolve()
ASSET = re.compile(r'''(\b(?:href|src)=)(["'])(/[^"'?#]+\.(?:css|js))\2''')

hashes: dict[str, str] = {}


def version(url_path: str) -> str | None:
    if url_path not in hashes:
        f = root / url_path.lstrip("/")
        hashes[url_path] = (
            hashlib.sha256(f.read_bytes()).hexdigest()[:10] if f.is_file() else ""
        )
    return hashes[url_path] or None


rewritten = 0
for page in root.rglob("*.html"):
    text = page.read_text(encoding="utf-8")

    def swap(m: re.Match) -> str:
        v = version(m.group(3))
        if v is None:
            return m.group(0)  # not a local file, leave untouched
        return f"{m.group(1)}{m.group(2)}{m.group(3)}?v={v}{m.group(2)}"

    new = ASSET.sub(swap, text)
    if new != text:
        page.write_text(new, encoding="utf-8")
        rewritten += 1

print(f"cache-bust: {rewritten} pages rewritten, {len(hashes)} assets hashed")

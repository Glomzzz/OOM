#!/usr/bin/env python3
"""Optimize only the deployment copy: CSS bundles, WOFF2 and nonblocking fonts.

Run before cache-bust.py / lazy-embeds.py. No network access or font subsetting:
all glyphs, OpenType features, source fonts and licenses are retained.
"""
from __future__ import annotations

import hashlib
import html
import io
import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import parse_qs, quote, unquote, urlencode, urljoin, urlsplit

from fontTools.ttLib import TTFont
from rcssmin import cssmin

URL = re.compile(r'''url\(\s*(["']?)([^)"']+)\1\s*\)(\s*format\(["'][^"']+["']\))?''', re.IGNORECASE)
# Known font providers can load after first paint. Other remote CSS must
# remain blocking and in its original cascade position.
FONT_HOSTS = {"fonts.googleapis.com"}
MATH_FONTS = "https://fred-wang.github.io/MathFonts/NewComputerModern/mathfonts.css"


class Head(HTMLParser):
    """Record source spans; never reserialize SVG, MathML or article markup."""

    def __init__(self, text: str):
        super().__init__(convert_charrefs=False)
        self.text = text
        self.lines = [0] + [m.end() for m in re.finditer("\n", text)]
        self.tags = []
        self.style = None
        self.noscript = False
        self.feed(text)
        self.close()

    def position(self):
        line, column = self.getpos()
        return self.lines[line - 1] + column

    def handle_starttag(self, tag, attrs):
        if tag == "noscript":
            self.noscript = True
        if self.noscript:
            return
        start = self.position()
        end = start + len(self.get_starttag_text())
        if tag in {"link", "script"}:
            self.tags.append((start, end, tag, dict(attrs), ""))
        elif tag == "style":
            self.style = (start, end, dict(attrs))

    handle_startendtag = handle_starttag

    def handle_endtag(self, tag):
        if tag == "noscript":
            self.noscript = False
        if tag == "style" and self.style:
            start, opening_end, attrs = self.style
            end = self.text.index(">", self.position()) + 1
            self.tags.append((start, end, tag, attrs, self.text[opening_end:self.position()]))
            self.style = None


def put(root: Path, content: bytes, suffix: str) -> str:
    digest = hashlib.sha256(content).hexdigest()[:20]
    url = f"/_assets/{digest}.{suffix}"
    file = root / url.lstrip("/")
    file.parent.mkdir(exist_ok=True)
    file.write_bytes(content)
    return url


def local_file(root: Path, url: str) -> Path:
    file = (root / unquote(urlsplit(url).path).lstrip("/")).resolve()
    if not file.is_relative_to(root):
        raise ValueError(f"Asset escapes deployment root: {url}")
    if not file.is_file():
        raise FileNotFoundError(file)
    return file


def google_fonts(tags) -> str | None:
    """Merge the site's default and wght-only CSS2 requests without losing faces.

    Unknown axes/query options opt out rather than silently changing typography.
    """
    families = {}
    for _, _, tag, attrs, _ in tags:
        parts = urlsplit(attrs.get("href") or "")
        if (tag != "link" or "stylesheet" not in (attrs.get("rel") or "").split()
                or parts.hostname != "fonts.googleapis.com"):
            continue
        query = parse_qs(parts.query)
        if (set(attrs) - {"rel", "href"} or parts.path != "/css2"
                or set(query) != {"family", "display"} or query["display"] != ["swap"]):
            return None
        for family in query["family"]:
            name, _, axes = family.partition(":")
            weights = families.setdefault(name, set())
            if not axes:
                weights.add("400")
            elif re.fullmatch(r"wght@[0-9;]+", axes):
                weights.update(axes.removeprefix("wght@").split(";"))
            else:
                return None
    if not families:
        return None
    query = [("family", name + ":wght@" + ";".join(sorted(weights, key=int)))
             for name, weights in sorted(families.items())]
    return "https://fonts.googleapis.com/css2?" + urlencode(query + [("display", "swap")], safe=":;@")


def optimize(root: Path):
    fonts = {}
    styles = {}

    def stylesheet(url: str) -> str:
        if url in styles:
            return styles[url]
        source = local_file(root, url).read_text(encoding="utf-8")
        # @import ordering/base URLs cannot safely be changed by concatenation.
        if re.search(r"@import\b|@charset\b", source, re.IGNORECASE):
            raise ValueError(f"Cannot bundle CSS containing @import/@charset: {url}")

        def rebase(match):
            value = match[2].strip()
            parts = urlsplit(value)
            if parts.scheme or parts.netloc or value.startswith("#"):
                return match[0]
            absolute = urljoin(url, value)
            format_hint = match[3] or ""
            if parts.path.lower().endswith((".otf", ".ttf")):
                if absolute not in fonts:
                    font = TTFont(local_file(root, absolute), recalcTimestamp=False)
                    font.flavor = "woff2"
                    buffer = io.BytesIO()
                    font.save(buffer)
                    font.close()
                    fonts[absolute] = put(root, buffer.getvalue(), "woff2")
                absolute = fonts[absolute]
                format_hint = ' format("woff2")'
            return f'url("{quote(absolute, safe="/:#?=&%")}"){format_hint}'

        source = URL.sub(rebase, source)
        styles[url] = cssmin(source)
        return styles[url]

    pages = 0
    for page in sorted(root.rglob("*.html")):
        text = page.read_text(encoding="utf-8")
        if "</head>" not in text:
            continue
        head = Head(text[:text.index("</head>")])
        merged_google = google_fonts(head.tags)
        replacements = []
        pending = []
        seen_fonts = set()

        def flush(pending=pending, replacements=replacements):
            if not pending:
                return
            url = put(root, "\n".join(css for _, _, css in pending).encode(), "css")
            for i, (start, end, _) in enumerate(pending):
                replacements.append((start, end, f'<link rel="stylesheet" href="{url}">' if i == 0 else ""))
            pending.clear()

        for start, end, tag, attrs, _ in sorted(head.tags):
            if tag in {"style", "script"}:
                # Don't move styles across inline rules or scripts which may
                # inspect the CSSOM. Keep media-specific rules in place too.
                flush()
                continue
            if "stylesheet" not in (attrs.get("rel") or "").split():
                continue
            url = attrs.get("href") or ""
            parts = urlsplit(url)
            if parts.hostname in FONT_HOSTS or url == MATH_FONTS:
                flush()
                if set(attrs) - {"rel", "href"}:
                    continue
                if parts.hostname == "fonts.googleapis.com" and merged_google:
                    url = merged_google
                if url in seen_fonts:
                    replacements.append((start, end, ""))
                    continue
                seen_fonts.add(url)
                escaped = html.escape(url, quote=True)
                # A nonmatching media query does not block first paint. This
                # also works with JS disabled via the ordinary noscript link.
                replacements.append((start, end, (
                    f'<link rel="stylesheet" href="{escaped}" media="print" '
                    'onload="this.media=\'all\'">'
                    f'<noscript><link rel="stylesheet" href="{escaped}"></noscript>')))
            elif (url.startswith("/") and not parts.netloc
                  and not url.startswith("/_assets/") and set(attrs) <= {"rel", "href"}):
                pending.append((start, end, stylesheet(url)))
            else:
                flush()
        flush()
        for start, end, replacement in sorted(replacements, reverse=True):
            text = text[:start] + replacement + text[end:]
        # Typsite currently regenerates the document tag with en-US even when
        # the schema specifies Chinese. Correct the generated deployment only.
        text = re.sub(r'(<html\b[^>]*\blang=)["\'][^"\']*["\']', r'\1"zh-CN"', text, count=1)
        page.write_text(text, encoding="utf-8")
        pages += 1
    print(f"optimize-assets: {pages} pages, {len(styles)} stylesheets, {len(fonts)} WOFF2 faces")


def main():
    optimize(Path(sys.argv[1] if len(sys.argv) > 1 else "publish").resolve())


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Split closed Typsite transclusions into content-addressed static fragments.

Run after `typsite c` and cache-bust.py. Open content and every standalone
article remain HTML. Closed embeds retain their summaries and a no-JS permalink.
A separate, on-demand index resolves anchors inside not-yet-loaded fragments.
Only source spans are replaced: SVG, MathML, code and whitespace are preserved.
"""
from __future__ import annotations

import hashlib
import html
import json
import re
import sys
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path

VOID = frozenset("area base br col embed hr img input link meta param source track wbr".split())


@dataclass(eq=False)
class Element:
    tag: str
    attrs: dict[str, str | None]
    start: int
    opening_end: int
    parent: Element | None = None
    children: list[Element] = field(default_factory=list)
    closing_start: int = 0
    end: int = 0

    def has_class(self, name: str) -> bool:
        return name in (self.attrs.get("class") or "").split()


class Spans(HTMLParser):
    def __init__(self, text: str):
        super().__init__(convert_charrefs=False)
        self.text = text
        self.lines = [0] + [m.end() for m in re.finditer("\n", text)]
        self.elements: list[Element] = []
        self.stack: list[Element] = []
        self.feed(text)
        self.close()

    def position(self) -> int:
        line, col = self.getpos()
        return self.lines[line - 1] + col

    def handle_starttag(self, tag, attrs):
        start = self.position()
        end = start + len(self.get_starttag_text())
        node = Element(tag, dict(attrs), start, end, self.stack[-1] if self.stack else None)
        if node.parent:
            node.parent.children.append(node)
        self.elements.append(node)
        if tag in VOID:
            node.closing_start = node.end = end
        else:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in VOID:
            node = self.stack.pop()
            node.closing_start = node.end = node.opening_end

    def handle_endtag(self, tag):
        # HTMLParser does not understand nesting. Match explicitly, including
        # SVG's case-insensitive parser names, without serializing its content.
        for i in range(len(self.stack) - 1, -1, -1):
            if self.stack[i].tag == tag:
                start = self.position()
                end = self.text.index(">", start) + 1
                for node in self.stack[i:]:
                    node.closing_start, node.end = start, end
                del self.stack[i:]
                break


def add_attrs(opening: str, **attrs: str) -> str:
    extra = "".join(f' {k.replace("_", "-")}="{html.escape(v, quote=True)}"' for k, v in attrs.items())
    return opening[:-1].rstrip() + extra + ">"


def canonical_slug(value: str) -> str:
    value = re.sub(r"\.html$", "", value).rstrip("/")
    value = re.sub(r"/index$", "", value)
    return value or "/"


def optimize_page(page: Path, root: Path) -> tuple[int, int]:
    text = page.read_text(encoding="utf-8")
    parsed = Spans(text)
    article = next((n for n in parsed.elements if n.tag == "article"), None)
    if article is None or "data-lazy-index" in article.attrs:
        return 0, 0

    candidates: list[Element] = []
    summaries: dict[Element, Element] = {}
    for node in parsed.elements:
        if (node.tag == "details" and "open" not in node.attrs
                and node.parent and node.parent.has_class("embed")):
            summary = next((c for c in node.children if c.tag == "summary"), None)
            if summary is None or not node.end or not summary.end:
                raise ValueError(f"{page}: incomplete embed details/summary")
            candidates.append(node)
            summaries[node] = summary
    if not candidates:
        return 0, 0

    keys = {node: f"e{i}" for i, node in enumerate(candidates)}
    replacements: dict[Element, str] = {}
    fragments = root / "_embeds"
    fragments.mkdir(exist_ok=True)

    def render(start: int, end: int) -> str:
        parts: list[str] = []
        position = start
        for node in candidates:
            if node.start < position or node.end > end:
                continue
            parts.extend((text[position:node.start], replacements[node]))
            position = node.end
        parts.append(text[position:end])
        return "".join(parts)

    # Children first: an outer fragment contains placeholders, not the full
    # bodies of its closed descendants. Keys are page-local, not content IDs.
    for node in reversed(candidates):
        body = render(summaries[node].end, node.closing_start)
        digest = hashlib.sha256(body.encode()).hexdigest()[:20]
        (fragments / f"{digest}.html").write_text(body, encoding="utf-8")
        slug = html.escape(node.parent.attrs.get("data-slug") or "/", quote=True)
        placeholder = (
            '<div class="lazy-embed-placeholder">'
            '<span class="lazy-embed-status" role="status" aria-live="polite"></span>'
            f'<a class="lazy-embed-fallback" href="{slug}">打开独立页面 →</a>'
            '</div>'
        )
        opening = add_attrs(text[node.start:node.opening_end],
                            data_lazy_key=keys[node], data_lazy_src=f"/_embeds/{digest}.html")
        replacements[node] = (
            opening + text[node.opening_end:summaries[node].end]
            + placeholder + text[node.closing_start:node.end]
        )

    def chain(node: Element) -> list[str]:
        owners = []
        parent = node.parent
        while parent:
            # A summary remains in its owner's HTML; only the body is split.
            if parent in keys and node.start >= summaries[parent].end:
                owners.append(keys[parent])
            parent = parent.parent
        return list(reversed(owners))

    anchors: dict[str, list[dict]] = {}
    slugs: dict[str, list[dict]] = {}

    def register(mapping: dict, name: str, record: dict):
        records = mapping.setdefault(name, [])
        if record not in records:
            records.append(record)

    for node in parsed.elements:
        owners = chain(node)
        if node.attrs.get("id") and owners:
            register(anchors, node.attrs["id"], {"anchor": node.attrs["id"], "chain": owners})
        if node.has_class("embed"):
            details = next((c for c in node.children if c.tag == "details"), None)
            summary = next((c for c in details.children if c.tag == "summary"), None) if details else None
            numbering = next((n for n in parsed.elements
                              if summary and summary.start < n.start < summary.end
                              and n.has_class("heading-numbering")), None)
            anchor = node.attrs.get("id") or (numbering.attrs.get("id") if numbering else None)
            if not anchor:
                raise ValueError(f"{page}: embed has no heading anchor")
            record = {"anchor": anchor, "chain": owners}
            slug = node.attrs.get("data-slug")
            if slug:
                register(slugs, canonical_slug(slug), record)
            for key in ("data-reference-id", "data-legacy-reference-id"):
                if node.attrs.get(key):
                    register(anchors, node.attrs[key], record)

    index = json.dumps({"version": 1, "anchors": anchors, "slugs": slugs},
                       ensure_ascii=False, separators=(",", ":"))
    digest = hashlib.sha256(index.encode()).hexdigest()[:20]
    (fragments / f"index-{digest}.json").write_text(index, encoding="utf-8")
    output = render(0, len(text))
    opening = text[article.start:article.opening_end]
    output = output.replace(opening, add_attrs(opening, data_lazy_index=f"/_embeds/index-{digest}.json"), 1)
    if not any(n.tag == "script" and "lazy-embeds.js" in (n.attrs.get("src") or "") for n in parsed.elements):
        # Run before site-links.js, so initial deep links can use the loader.
        asset_hash = hashlib.sha256((root / "lazy-embeds.js").read_bytes()).hexdigest()[:10]
        script = f'<script defer src="/lazy-embeds.js?v={asset_hash}"></script>\n'
        site_links = re.search(r'<script\b[^>]*\bsrc=["\'][^"\']*site-links\.js[^"\']*["\'][^>]*>', output)
        if site_links:
            output = output[:site_links.start()] + script + output[site_links.start():]
        else:
            output = output.replace("</head>", script + "</head>", 1)
    page.write_text(output, encoding="utf-8")
    return len(candidates), len(text.encode()) - len(output.encode())


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "publish").resolve()
    if not (root / "lazy-embeds.js").is_file():
        raise SystemExit(f"{root}/lazy-embeds.js is missing; compile the site assets first")
    count = saved = pages = 0
    for page in sorted(root.rglob("*.html")):
        if "_embeds" in page.relative_to(root).parts:
            continue
        n, size = optimize_page(page, root)
        count += n
        saved += size
        pages += bool(n)
    print(f"lazy-embeds: {count} embeds split across {pages} pages; {saved:,} initial HTML bytes removed")


if __name__ == "__main__":
    main()

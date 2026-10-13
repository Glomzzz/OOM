#!/usr/bin/env python3
"""Check the built site's academic heading conventions without dependencies.

Usage: python3 .github/scripts/check-academic-style.py [publish-dir]
Checks static HTML, so taxon order and independent links cannot rely on JS.
"""
from collections import Counter
from dataclasses import dataclass, field
from functools import cache
from html.parser import HTMLParser
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

KINDS = {
    "definition": "Definition",
    "theorem": "Theorem",
    "lemma": "Lemma",
    "corollary": "Corollary",
    "example": "Example",
    "convention": "Convention",
    "note": "Note",
    "remark": "Remark",
}
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}


@dataclass
class Element:
    tag: str
    attrs: dict[str, str | None] = field(default_factory=dict)
    children: list = field(default_factory=list)

    def has_class(self, name: str) -> bool:
        return name in (self.attrs.get("class") or "").split()

    def elements(self):
        return [node for node in self.children if isinstance(node, Element)]

    def walk(self):
        yield self
        for child in self.elements():
            yield from child.walk()

    def text(self) -> str:
        return " ".join("".join(
            child.text() if isinstance(child, Element) else child
            for child in self.children
        ).split())


class Document(HTMLParser):
    def __init__(self, text: str):
        super().__init__(convert_charrefs=True)
        self.root = Element("document")
        self.stack = [self.root]
        self.feed(text)
        self.close()

    def handle_starttag(self, tag, attrs):
        node = Element(tag, dict(attrs))
        self.stack[-1].children.append(node)
        if tag not in VOID:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.stack[-1].children.append(Element(tag, dict(attrs)))

    def handle_endtag(self, tag):
        for i in range(len(self.stack) - 1, 0, -1):
            if self.stack[i].tag == tag:
                del self.stack[i:]
                break

    def handle_data(self, data):
        self.stack[-1].children.append(data)


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def child(node, tag):
    return next(el for el in node.elements() if el.tag == tag)


def heading(section):
    return child(child(child(section, "details"), "summary"), "header")


def destination(root, url):
    parts = urlsplit(url)
    check(not parts.scheme and not parts.netloc, f"Expected a local URL: {url}")
    path = unquote(parts.path).lstrip("/")
    if not path or path.endswith("/"):
        path += "index.html"
    elif not Path(path).suffix:
        path += ".html"
    return root / path


@cache
def statement_title(page):
    doc = Document(page.read_text(encoding="utf-8")).root
    title = next(node for node in doc.walk() if node.tag == "h1")
    return Element("h1", children=[
        node for node in title.children
        if not (isinstance(node, Element) and node.has_class("taxon"))
    ]).text()


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "publish").resolve()
    pages = sorted(root.rglob("*.html"))
    check(pages, f"No built HTML found in {root}")
    counts = Counter()
    demos = {}

    for page in pages:
        doc = Document(page.read_text(encoding="utf-8")).root
        nodes = list(doc.walk())
        title = next(node.text() for node in nodes if node.tag == "title")
        check(any(node.tag == "article" and node.attrs.get("lang") == "zh-CN" for node in nodes),
              f"{page}: prose must declare its language")
        check(any(node.tag == "link" and urlsplit(node.attrs.get("href") or "").path == "/fonts.css" for node in nodes),
              f"{page}: missing shared font stylesheet")

        for section in (node for node in nodes if node.has_class("embed") or node.has_class("page-root")):
            slug = section.attrs.get("data-slug") or ""
            taxon = section.attrs.get("data-taxon") or ""
            if slug.startswith("/statements/"):
                kind = slug.split("/")[2]
                check(taxon == KINDS[kind], f"{page}: {slug} has taxon {taxon!r}")
                if section.has_class("page-root"):
                    check(title.startswith(taxon + ". "), f"{page}: browser title lost its English kind")
                    counts["statements"] += 1

            if section.has_class("embed"):
                labels = heading(section).elements()
                check([el.attrs.get("class") for el in labels[:3]] == ["taxon", "heading-numbering", "embed-title"],
                      f"{page}: expected taxon → numbering → title for {slug}")
                check(labels[0].text() == taxon, f"{page}: bracketed or repeated taxon in {slug}")
                check(labels[0].attrs.get("lang") == "en", f"{page}: English taxon must declare its language")
                number = labels[1].text()
                check(not number or re.fullmatch(r"\d+(?:\.\d+)*|[A-Z.]+", number),
                      f"{page}: numbering is not a native counter: {number!r}")
                counts["embeds"] += 1
                if page.relative_to(root).as_posix() == "how/plt/prelude.html":
                    demos[taxon] = "open" in child(section, "details").attrs

        for node in nodes:
            if node.has_class("statement-ref"):
                link = child(node, "a")
                url = link.attrs.get("href") or ""
                target = destination(root, url)
                check(target.is_file(), f"{page}: broken no-JS statement link {url}")
                check(link.text() == statement_title(target),
                      f"{page}: citation should show only the target title, without a taxon or local number")
                counts["references"] += 1
            if node.has_class("proof-head"):
                check(node.text() == "Proof." or node.text().startswith("Proof ("),
                      f"{page}: proof heading must use English")
                counts["proofs"] += 1
            if node.has_class("qed"):
                check(node.text() == "∎", f"{page}: missing proof-end symbol")

    check(set(demos) == set(KINDS.values()), "Prelude must demonstrate all eight English environments")
    for kind, is_open in demos.items():
        check(is_open == (kind not in {"Note", "Remark"}), f"Default fold state changed for {kind}")

    fonts = root / "fonts.css"
    check(fonts.is_file(), "Missing local font stylesheet")
    for url in re.findall(r'url\("([^\"]+)"\)', fonts.read_text()):
        check((fonts.parent / unquote(url)).is_file(), f"Missing local font: {url}")
    check(counts["statements"] and counts["proofs"] and counts["references"], "No statements, proofs or references checked")
    print(f"academic-style: {len(pages)} pages; {counts['statements']} statements; "
          f"{counts['embeds']} embeds; {counts['references']} references; {counts['proofs']} proofs — passed")


if __name__ == "__main__":
    main()

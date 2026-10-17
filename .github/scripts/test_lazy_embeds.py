"""Unit tests: python3 -m unittest discover -s .github/scripts -p 'test_*.py'."""
import hashlib
import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("lazy_embeds", Path(__file__).with_name("lazy-embeds.py"))
lazy = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = lazy
spec.loader.exec_module(lazy)

SVG = '<svg viewBox="0 0 10 20"><defs><symbol id="glyph"><path d="M0,1 L2,3"/></symbol></defs><use href="#glyph"/></svg>'
MATH = '<math><mrow><mi>t</mi><mo>→</mo><mi>u</mi></mrow></math>'
FIXTURE = '''<!doctype html><html><head><script defer src="/site-links.js?v=abc"></script></head>
<body><article><section class="page-root" id="root"><details open><summary>根</summary>
<section class="embed block" data-slug="/outer/index"><details><summary><header><span class="heading-numbering" id="outer-1">1</span>外层</header></summary>
<p id="outer-body">正文 {math}</p>
<section class="block embed" data-slug="/inner" data-reference-id="definition/inner" data-legacy-reference-id="fm-inner"><details><summary><header><span class="heading-numbering" id="inner-1.1">1.1</span>内层</header></summary>
<p id="inner-body">深层 {svg}</p></details></section>
</details></section>
<section class="block embed" data-slug="/open"><details open><summary><span class="heading-numbering" id="open-2">2</span>已展开</summary><p id="open-body">Keep open content.</p></details></section>
<section class="block"><details><summary>补充</summary><p id="supplement">Keep non-embed details.</p></details></section>
</details></section></article></body></html>'''.format(math=MATH, svg=SVG)


class LazyEmbedTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "lazy-embeds.js").write_text("/* loader */")
        self.page = self.root / "index.html"
        self.page.write_text(FIXTURE)

    def optimize(self):
        lazy.optimize_page(self.page, self.root)
        output = self.page.read_text()
        parsed = lazy.Spans(output)
        url = next(n.attrs["data-lazy-index"] for n in parsed.elements if n.tag == "article")
        index = json.loads((self.root / url.lstrip("/")).read_text())
        return output, parsed, index

    def test_only_closed_embeds_split_and_unicode_spans_preserved(self):
        output, _, _ = self.optimize()
        self.assertIn('id="open-body"', output)
        self.assertIn('id="supplement"', output)
        self.assertIn("外层", output)
        self.assertNotIn('id="outer-body"', output)
        self.assertNotIn('id="inner-body"', output)
        self.assertIn('href="/outer/index"', output)
        self.assertIn('src="/lazy-embeds.js?v=', output)
        self.assertLess(output.index("lazy-embeds.js"), output.index("site-links.js"))
        chunks = [p.read_text() for p in (self.root / "_embeds").glob("*.html")]
        self.assertTrue(any(SVG in c for c in chunks))
        self.assertTrue(any(MATH in c for c in chunks))

    def test_nested_anchor_chains_exclude_their_own_summaries(self):
        _, _, index = self.optimize()
        self.assertNotIn("outer-1", index["anchors"])
        self.assertEqual(index["anchors"]["inner-1.1"][0]["chain"], ["e0"])
        self.assertEqual(index["anchors"]["inner-body"][0]["chain"], ["e0", "e1"])
        self.assertEqual(index["anchors"]["fm-inner"][0]["anchor"], "inner-1.1")
        self.assertEqual(index["slugs"]["/outer"][0]["chain"], [])
        self.assertEqual(index["slugs"]["/inner"][0]["chain"], ["e0"])

    def test_every_fragment_is_content_addressed_and_references_exist(self):
        output, _, _ = self.optimize()
        for chunk in (self.root / "_embeds").iterdir():
            digest = hashlib.sha256(chunk.read_bytes()).hexdigest()[:20]
            self.assertIn(digest, chunk.name)
            if chunk.suffix == ".html":
                output += chunk.read_text()
        for node in lazy.Spans(output).elements:
            if node.attrs.get("data-lazy-src"):
                self.assertTrue((self.root / node.attrs["data-lazy-src"].lstrip("/")).is_file())

    def test_idempotent(self):
        output, _, _ = self.optimize()
        self.assertEqual(lazy.optimize_page(self.page, self.root), (0, 0))
        self.assertEqual(output, self.page.read_text())

    def test_pages_without_closed_embeds_are_untouched(self):
        text = '<html><head></head><body><article><details open><summary>Open</summary>Text</details></article></body></html>'
        self.page.write_text(text)
        self.assertEqual(lazy.optimize_page(self.page, self.root), (0, 0))
        self.assertEqual(text, self.page.read_text())


if __name__ == "__main__":
    unittest.main()

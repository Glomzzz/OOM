"""Asset transformations preserve layout order, URLs and full font coverage."""
import hashlib
import importlib.util
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from fontTools.ttLib import TTFont

spec = importlib.util.spec_from_file_location("assets", Path(__file__).with_name("optimize-assets.py"))
assets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(assets)
ROOT = Path(__file__).resolve().parents[2]


class AssetTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "styles").mkdir()
        (self.root / "styles/a.css").write_text('/* comment */ p { color: red; background: url("../image%20one.svg#icon"); }')
        (self.root / "styles/b.css").write_text('p { color: blue; margin: calc(1rem + 2px); }')
        (self.root / "styles/c.css").write_text('p { color: green; }')
        self.page = self.root / "index.html"

    def test_bundles_preserve_cascade_and_relative_urls(self):
        body = '<body><article><svg viewBox="0 0 1 2"><use href="#glyph"/></svg><math><mi>λ</mi></math>中文</article></body>'
        self.page.write_text('''<html lang="en-US"><head>
<link rel="stylesheet" href="/styles/a.css"><link href="/styles/b.css" rel="stylesheet">
<style>p { color: pink; }</style><link href="/styles/c.css" rel="stylesheet">
<link href="/styles/c.css" rel="stylesheet" media="print">
<link href="https://example.com/layout.css" rel="stylesheet"></head>''' + body)
        assets.optimize(self.root)
        text = self.page.read_text()
        self.assertIn('lang="zh-CN"', text)
        self.assertTrue(text.endswith(body))
        urls = re.findall(r'href="(/_assets/[^"]+\.css)"', text)
        self.assertEqual(len(urls), 2)
        first = (self.root / urls[0].lstrip("/")).read_text()
        self.assertLess(first.index("color:red"), first.index("color:blue"))
        self.assertIn('url("/image%20one.svg#icon")', first)
        self.assertIn("calc(1rem + 2px)", first)
        self.assertNotIn("comment", first)
        self.assertLess(text.index(urls[0]), text.index("<style>"))
        self.assertLess(text.index("<style>"), text.index(urls[1]))
        self.assertIn('<link href="/styles/c.css" rel="stylesheet" media="print">', text)
        self.assertIn('<link href="https://example.com/layout.css" rel="stylesheet">', text)
        for url in urls:
            data = (self.root / url.lstrip("/")).read_bytes()
            self.assertIn(hashlib.sha256(data).hexdigest()[:20], url)
        assets.optimize(self.root)
        self.assertEqual(text, self.page.read_text())

    def test_remote_font_css_is_nonblocking_deduplicated_with_no_js_fallback(self):
        noto = 'https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;600;700&amp;display=swap'
        combined = 'https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;600&amp;family=LXGW+WenKai+TC&amp;display=swap'
        self.page.write_text(f'<head><link rel="stylesheet" href="{noto}"><link rel="stylesheet" href="{combined}"><link rel="stylesheet" href="{noto}"></head>')
        assets.optimize(self.root)
        text = self.page.read_text()
        tags = assets.Head(text).tags
        self.assertEqual(len(tags), 1)
        attrs = tags[0][3]
        self.assertEqual(attrs["media"], "print")
        self.assertEqual(attrs["onload"], "this.media='all'")
        self.assertIn("Noto+Serif+SC:wght@400;600;700", attrs["href"])
        self.assertIn("LXGW+WenKai+TC:wght@400", attrs["href"])
        self.assertIn("<noscript><link rel=\"stylesheet\"", text)
        assets.optimize(self.root)
        self.assertEqual(text, self.page.read_text())

    def test_media_attributes_and_script_cascade_barriers_are_preserved(self):
        self.page.write_text('''<head>
<link rel="stylesheet" href="/styles/a.css"><script>/* CSSOM reader */</script>
<link rel="stylesheet" href="/styles/b.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Example&amp;display=swap" media="screen">
</head>''')
        assets.optimize(self.root)
        text = self.page.read_text()
        urls = re.findall(r'href="(/_assets/[^"]+\.css)"', text)
        self.assertEqual(len(urls), 2)
        self.assertLess(text.index(urls[0]), text.index("<script>"))
        self.assertLess(text.index("</script>"), text.index(urls[1]))
        self.assertIn('media="screen"', text)
        self.assertNotIn("<noscript>", text)

    def test_content_addressed_css_is_not_double_versioned(self):
        self.page.write_text('<head><link rel="stylesheet" href="/styles/a.css"></head>')
        assets.optimize(self.root)
        expected = self.page.read_text()
        subprocess.run([sys.executable, str(Path(__file__).with_name("cache-bust.py")), str(self.root)], check=True, capture_output=True)
        self.assertEqual(expected, self.page.read_text())

    def test_unknown_google_font_axes_are_not_merged(self):
        self.page.write_text('<head><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Example:ital,wght@0,400;1,700&amp;display=swap"></head>')
        assets.optimize(self.root)
        self.assertIn("Example:ital,wght@0,400;1,700", self.page.read_text())

    def test_woff2_preserves_all_glyphs_and_layout_tables(self):
        source = ROOT / ".typsite/assets/fonts/manufacturing-consent/ManufacturingConsent-Regular.ttf"
        (self.root / "face.ttf").write_bytes(source.read_bytes())
        css = '@font-face { font-family: Test; src: url("../face.ttf") format("truetype"); font-display: swap; }'
        (self.root / "styles/a.css").write_text(css)
        self.page.write_text('<head><link rel="stylesheet" href="/styles/a.css"></head>')
        assets.optimize(self.root)
        font_file, = (self.root / "_assets").glob("*.woff2")
        with TTFont(source) as original, TTFont(font_file) as web:
            self.assertEqual(original.getBestCmap(), web.getBestCmap())
            self.assertEqual(original.getGlyphOrder(), web.getGlyphOrder())
            for tag in ("GSUB", "GPOS", "name"):
                self.assertEqual(original[tag].compile(original), web[tag].compile(web))
        bundle, = (self.root / "_assets").glob("*.css")
        self.assertIn('format("woff2")', bundle.read_text())
        self.assertIn("font-display:swap", bundle.read_text())
        self.assertLess(font_file.stat().st_size, source.stat().st_size)
        self.assertEqual((self.root / "styles/a.css").read_text(), css)
        self.assertEqual((self.root / "face.ttf").read_bytes(), source.read_bytes())

    def test_missing_traversal_and_imports_fail_instead_of_shipping_broken_css(self):
        for url in ("/missing.css", "/../outside.css", "/styles/a.css"):
            with self.subTest(url=url):
                (self.root / "styles/a.css").write_text('@import "other.css";')
                self.page.write_text(f'<head><link rel="stylesheet" href="{url}"></head>')
                with self.assertRaises((FileNotFoundError, ValueError)):
                    assets.optimize(self.root)


if __name__ == "__main__":
    unittest.main()

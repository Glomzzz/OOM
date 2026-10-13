# Typsite Template

See: [Typsite](https://github.com/Glomzzz/typsite)

First and foremost, prepare your Nix and Flake:
-   Ensure you have enabled `experimental-features = nix-command flakes` in your Nix configuration.

```bash
git clone https://github.com/Glomzzz/typsite-template your-site
cd your-site
nix develop
```

Then enjoy your typsite env !

## Fonts

Fonts used by `root/how/plt/formal/index.typ` are provided in `.typsite/assets/fonts`.
Typsite loads this directory automatically; `nix develop` and GitHub Actions
also set `TYPST_FONT_PATHS` for direct Typst compilation.
HTML prose and theorem labels load the local Libertinus Serif faces through
`.typsite/assets/fonts.css`; Chinese prose uses Noto Serif SC with system
Song-style serif fallbacks. The UI keeps Inria Sans. The font directories
include their OFL licenses.

## Academic style

The site uses a centred reading column, serif prose, restrained rules and
muted metadata, inspired by [回声](https://kokic.github.io/blog/). Coloured
statement cards remain, with lighter tints and ink-like accents in both light
and dark modes. Folding, independent-page links, citations, the contents
drawer, legacy anchors and the formula-text toggle are preserved.

Environment names are English (`Definition`, `Theorem`, `Lemma`, `Corollary`,
`Example`, `Convention`, `Note`, `Remark`). Embed headers read
`Theorem 2.1. 标题`: taxon precedes the native heading number. Citations show
only the title, without a taxon prefix or context-dependent number. Proofs start with
`Proof.` and end with ∎; exercises use `Exercise`, `Hint` and `Solution`.
The build checks English taxons, static header order, independent statement
links, default folding, proof labels and local font files:

```bash
python3 .github/scripts/check-academic-style.py publish
```

## Formalization series

The entrypoint is `root/how/plt/formal/index.typ`. It embeds ten articles and
80 independently linkable statements, using typsite's native numbering and
taxon-based colours. Statements are shared site-wide under `root/statements/`,
classified by kind with full lowercase hyphenated filenames. Each file owns
its title, metadata, statement and proof; no separate catalogue is required.
References show only the title, not the kind or a local number.
See [statement authoring](root/statements/README.md).

MathML is used where supported. SVG equation fallbacks keep their layout and
include static text alternatives for assistive technology and text extraction.
The fixed 𝑓 button beside the top-right sidebar control toggles the fallbacks
to selectable text, with “显示公式文本” / “显示公式排版” tooltips. Rule and derivation
alternatives retain their premises, conclusions and rule names. The helper is
`root/lib/math-accessibility.typ`; its assertions can be run with:

```bash
typst compile --features html --root root root/lib/tests/math-accessibility.typ /tmp/math-accessibility.pdf
cargo test --release --manifest-path code/plt-arith/Cargo.toml
```

## Github Workflows

Also, this template provides a github action to automatically build the site, then try to deploy it on the github page.

Please check your repo's github page settings first\~\~


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
also set `TYPST_FONT_PATHS` for direct Typst compilation. HTML pages load the
corresponding fonts through external stylesheets in `<head>`.
The font directories include their OFL licenses.

## Formalization series

The entrypoint is `root/how/plt/formal/index.typ`. It embeds ten articles and
75 independently linkable statements, using typsite's native numbering and
taxon-based colours. Statements are shared site-wide under `root/statements/`,
classified by kind with full lowercase hyphenated filenames. Each file owns
its title, metadata, statement and proof; no separate catalogue is required.
References show the kind and title, not a local number.
See [statement authoring](root/statements/README.md).

## Github Workflows

Also, this template provides a github action to automatically build the site, then try to deploy it on the github page.

Please check your repo's github page settings first\~\~


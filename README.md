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

Fonts used by `root/how/plt/formal.typ` are provided in `.typsite/assets/fonts`.
Typsite loads this directory automatically; `nix develop` and GitHub Actions
also set `TYPST_FONT_PATHS` for direct Typst compilation. HTML pages load the
corresponding fonts through external stylesheets in `<head>`.
See [font versions, licenses, and verification](.typsite/assets/fonts/README.md).

## Github Workflows

Also, this template provides a github action to automatically build the site, then try to deploy it on the github page.

Please check your repo's github page settings first\~\~


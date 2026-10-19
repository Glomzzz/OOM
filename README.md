# Written in Typsite

See: [Typsite](https://github.com/Glomzzz/typsite)

Typsite **0.1.8**, Typst **0.15.1**. Nix pins the published GitHub release
[**`0.1.8-55`**](https://github.com/Glomzzz/typsite/releases/tag/0.1.8-55)
(`6a22a3558ffa474dae610f56a89f30a92e4b78a2`) and uses its upstream package.
CI downloads the same release's checksum-verified Linux binary; no local
Typsite checkout is required.

```sh
nix develop
export TYPST_PACKAGE_PATH="$PWD/.typst-packages"
python3 scripts/build.py
python3 -m http.server --bind 127.0.0.1 --directory publish 8000
```

The production helper keeps Typsite's raw output in `.cache/site/`, then optimizes
assets, hashes URLs and splits lazy embeds in a staging copy before replacing
`publish/`. Deployment helpers and tests remain tracked; local reports under
`docs/` and benchmark tooling under `scripts/perf/` are ignored.

### Production asset optimization

`.github/scripts/optimize-assets.py` runs without network access. It:

- Bundles/minifies local CSS in cascade order, preserving inline and media-specific
  styles and rebasing relative asset URLs.
- Converts all eight locally referenced Latin font faces to content-addressed
  WOFF2 **without subsetting**. Original Typst font inputs and licenses stay intact.
- Merges overlapping Google Fonts family/weight requests and loads remote font
  stylesheets without blocking first paint, with ordinary `<noscript>` fallbacks.
  Chinese serif, essay and math typography are retained; on a slow font connection,
  the existing fallback fonts render first. Remote fonts are still downloaded.
- Corrects Typsite's generated document language to `zh-CN`. The page schema also
  supplies a main landmark and a page-title-based search description.

`nix develop` supplies FontTools, Brotli and rcssmin. Outside Nix, install the
pinned tools in a virtual environment before building/testing:

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r .github/scripts/requirements.txt
python3 -m unittest discover -s .github/scripts -p 'test_*.py'
```

Only content-addressed `/_assets/` and `/_embeds/` files receive one-year immutable
cache headers. Fixed-name CSS/JS and HTML retain Cloudflare Pages' default
revalidation; do not apply immutable caching to them.

Local verification with Lighthouse 13.5 / Chromium 151, cold browser contexts,
local gzip hosting and **real third-party font requests enabled**: three final
runs yielded a **94 mobile median** (90–98) and **99 desktop median** (99–100).
Mobile median FCP/LCP were **2.26s / 2.57s**, with zero TBT; accessibility,
best practices and SEO scored 100. The unoptimized snapshot measured 55–56 on
mobile in two local runs (FCP 11.4–12.2s). These are local lab results, not a
production PageSpeed retest or a field-performance guarantee. Remote fonts still
account for substantial transfer and run-to-run timing variation.

## Cloudflare Pages deployment

Production is hosted at **https://glomzzz.com/** by the Cloudflare Pages
**`oom`** project (Direct Upload), with **`main`** as its production branch.
The Cloudflare-provided address is **https://oom-e0d.pages.dev/**. GitHub Actions
builds and tests every push and pull request, but only `main` pushes or manual
runs on `main` deploy.
The workflow uploads `publish/`; Cloudflare does not need a build command or
Git integration.

One-time setup:

1. Create the Direct Upload project if it does not exist:
   `npx wrangler@4.151.1 pages project create oom --production-branch=main --force`.
   `--force` keeps new project creation on Pages rather than delegating to Workers;
   it is not needed for deployments to the existing project.
2. In Cloudflare, create an API token with **Account → Cloudflare Pages → Edit**,
   restricted to the account containing `oom`.
3. Add GitHub Actions repository secrets in `Glomzzz/OOM`:
   - `CLOUDFLARE_ACCOUNT_ID`: the Cloudflare account ID.
   - `CLOUDFLARE_API_TOKEN`: the scoped API token. Do not commit this token or
     reuse Wrangler's local OAuth credentials. To enter it without putting it
     in shell history, run `gh secret set CLOUDFLARE_API_TOKEN --repo Glomzzz/OOM`.
4. Push to `main`, or run **Deploy to Cloudflare Pages** manually on `main`.
   The workflow's `cloudflare-pages` environment shows the deployment URL.

To upload an already built site locally after `npx wrangler@4.151.1 login`:

```sh
npx wrangler@4.151.1 pages deploy publish --project-name=oom --branch=main
```

`wrangler.jsonc` identifies the Pages project and its `publish/` output directory,
preventing Wrangler from picking up an unrelated parent-directory configuration.
The production build copies host-specific files from `.github/pages/` into its
staging output without modifying Typsite's raw files. Cloudflare serves
extensionless HTML routes and the included `404.html` prevents missing pages
from falling back to the homepage. `.github/pages/_headers` sets long caching
only for content-addressed assets/fragments; leave other Pages caching defaults
in place. Add any custom domain through **Workers & Pages → oom → Custom domains**
first, then follow Cloudflare's DNS instructions; a CNAME change alone is not
sufficient. Disable the old GitHub Pages site in the repository's **Settings →
Pages** after verifying Cloudflare (and any custom domain) works.

写作约定见[写作风格指引](root/how/style.typ)，涵盖中文表达、文章结构与 Typst／Typsite 写法。


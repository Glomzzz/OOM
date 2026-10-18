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

The production helper keeps Typsite's raw output in `.cache/site/`, then applies
asset hashing and lazy-embed splitting to a staging copy before replacing
`publish/`. Deployment helpers and tests remain tracked; local reports under
`docs/` and benchmark tooling under `scripts/perf/` are ignored.

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
from falling back to the homepage. Leave Pages' default caching in place.
Add any custom domain through **Workers & Pages → oom → Custom domains**
first, then follow Cloudflare's DNS instructions; a CNAME change alone is not
sufficient. Disable the old GitHub Pages site in the repository's **Settings →
Pages** after verifying Cloudflare (and any custom domain) works.

写作约定见[写作风格指引](root/how/style.typ)，涵盖中文表达、文章结构与 Typst／Typsite 写法。


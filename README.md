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

写作约定见[写作风格指引](root/how/style.typ)，涵盖中文表达、文章结构与 Typst／Typsite 写法。


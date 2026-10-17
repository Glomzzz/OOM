# Site performance: diagnosis, optimization and benchmarks

## What was slow?

The deployed homepage inspected during this investigation contained **3.93 MB of
HTML, about 47,000 elements, 119 inline SVGs and 1,370 MathML formulas**. Most
belonged to collapsed transclusions. A closed `<details>` hides content, but does
not avoid downloading/parsing its HTML, creating its DOM, or querying it in JS.

There was also a concrete layout bottleneck in `math-fit.js`:

- A Firefox-specific intrinsic-width workaround ran in Chromium too.
- It measured formulas in closed subtrees and observed every formula wrapper.
- Startup `toggle`, font and resize events caused repeated read/write passes.

An exploratory, three-run unthrottled homepage comparison reduced layout passes
from 180 to 6 by disabling that workaround in Chromium. Removing SVG contents
reduced HTML weight but left most blocking time intact. Naively adding
`content-visibility: auto` to every embed made the homepage slower. These were
**diagnostic prototypes**, not the final before/after benchmark below.

## Implemented

1. **Build-time splitting of closed embeds.** `.github/scripts/lazy-embeds.py`
   moves only closed `.embed > details` bodies into content-addressed HTML files
   under `/_embeds/`. Their summaries, native numbering and standalone links stay
   in the initial HTML. Nested closed embeds are split recursively. Initially
   open content stays inline; SVG, MathML, code and text are copied losslessly.
2. **On-demand enhancement.** `lazy-embeds.js` fetches a fragment when its fold is
   opened. Reopening it does not fetch again. A separate JSON index is requested
   only for navigation to a not-yet-loaded anchor/citation, not on normal startup.
3. **Navigation integration.** `site-links.js` indexes newly inserted subtrees,
   retains native numbering, resolves nested/legacy hashes and repeated
   statement citations, and keeps a stable source-link handle for Back.
4. **Bounded math work.** The width workaround is feature-gated to Firefox,
   skips closed bodies, batches events into animation frames, avoids unchanged
   style writes, and discovers formulas when fragments arrive. The accessible
   formula-text toggle is also installed when the first SVG formula arrives.
5. **Failure/no-JS support.** Loading/error status, retry and an ordinary
   standalone-page link remain available. No runtime framework or server was
   added: all deployed files are static.

The tested build split **281 embed occurrences across 22 pages**, removing
**15,650,593 bytes from their combined initial HTML**. This is a reduction in
initial page cost, **not** a claim that the total hosting artifact shrank:
fragments, navigation indexes and context-specific anchors add files/storage.

## Final measurements

Both variants came from the **same fresh production compilation**. The before
variant used the previous JS/CSS; the after variant used the updated assets and
embed postprocessor. Its generated HTML differs from the deployed snapshot
above, so compare the two columns here, not their byte sizes with the live audit.

Method:

- Chromium **153.0.8010.52**, headless, 390 × 844 viewport, DPR 1.
- Three runs per variant/page, fresh browser contexts, HTTP cache disabled.
- Local HTTP server with gzip, alternating before/after order between runs.
- Mobile-style profile: **4× CPU slowdown, 1.6 Mbps download, 0.75 Mbps upload,
  150 ms latency**. This is a simulation, not a physical-phone test.
- Third-party requests, including Google/MathFonts stylesheets, were fulfilled
  with empty responses consistently. Local CSS, fonts, images and scripts were
  still served. This isolates site work from external font-service variability;
  it does **not** model total real-world font/CDN latency.
- Observe through `load + 1500 ms`, then separately time opening the homepage's
  “寻径” (`/how/index`) fold through two animation frames after content is ready.
- “Blocking” = sum of `max(0, longTaskDuration − 50 ms)` in that observation
  window. This is **not Lighthouse TBT, INP or a Lighthouse score**. DCL is
  DOMContentLoaded; it is not the first time the page becomes visible.

### Mobile-style profile — medians

| Metric | Homepage before | Homepage after |
|---|---:|---:|
| Initial HTML, decoded | 4,307,931 B | 64,971 B |
| Initial HTML, gzip | 908,235 B | 8,626 B |
| DOM elements | 47,236 | 1,070 |
| DOMContentLoaded | 10.486 s | 0.847 s |
| First contentful paint | 0.848 s | 0.788 s |
| Largest contentful paint | 0.848 s | 0.788 s |
| `load` event | 13.063 s | 3.754 s |
| Main-thread blocking | 2,885 ms | 0 ms |
| Layout passes | 181 | 7 |
| Initial transfer, all measured resources | 1,978,729 B | 604,073 B |
| Deferred fragment/index requests at startup | 0 | 0 |
| First expansion of `/how/index` | 101 ms | 196 ms |

The homepage has **99% less compressed HTML**, **98% fewer DOM elements** and
about **12× earlier DCL**. First paint improves only slightly: the important win
is avoiding seconds of download/DOM processing and interaction-blocking work
*after* that first paint. The deferred first expansion adds about **95 ms** in
this profile. Opening the same fold again uses the inserted content.

| Metric | Math-heavy evaluation article before | After |
|---|---:|---:|
| Initial HTML, gzip | 89,629 B | 67,738 B |
| DOM elements | 3,933 | 2,979 |
| DOMContentLoaded | 1.326 s | 1.145 s |
| First contentful paint | 1.104 s | 1.096 s |
| `load` event | 6.330 s | 6.349 s |
| Main-thread blocking | 150 ms | 89 ms |
| Initial transfer | 1,120,787 B | 1,101,603 B |

The standalone article improves less: its intentionally visible formulas still
render, and font downloads still dominate its load event. We have **not** solved
all article/font performance by fixing the homepage.

### Unthrottled profile — medians

Same viewport and isolation, without CPU/network throttling:

| Page | DCL before → after | Blocking before → after | First expansion before → after |
|---|---:|---:|---:|
| Homepage | 1,050 → 99 ms | 677 → 0 ms | 21 → 32 ms |
| Evaluation article | 281 → 223 ms | 16 → 0 ms | — |

Raw runs and medians: [mobile.json](performance/mobile.json),
[unthrottled.json](performance/unthrottled.json).

## Reading/search/print trade-offs

- An unopened embed's body is not in the DOM yet. Its first expansion needs a
  network request. Previously loaded content remains usable in that document.
- Browser Find cannot search content that has not been fetched. Use the footer
  **“加载全文（查找／打印）”** control before whole-tree Find.
- Once loaded, **“打印全文”** opens folds, waits for fonts/layout, invokes printing,
  then restores the previous folds. Plain Ctrl+P prints what is currently loaded;
  `beforeprint` cannot synchronously finish arbitrary network requests.
- Without JS, each fold offers an ordinary link to its standalone page. Open
  prose remains static HTML; closed supplemental material is reachable through
  its own page rather than expanded inline. Crawlers can follow those links.
- Fragments are content-addressed, but GitHub Pages still controls HTTP cache
  headers. A page left open across deployments can encounter an old fragment
  URL; its retry/permalink is the fallback.
- Child-page stylesheets are still merged into collection-page heads by
  Typsite. This patch does not yet defer those font/CSS imports.

## Build / preview

Run from the repository root, with Typsite/Typst and the project fonts available:

```sh
export TYPST_FONT_PATHS="$PWD/.typsite/assets/fonts"
typsite c --p packages
python3 .github/scripts/cache-bust.py publish
python3 .github/scripts/lazy-embeds.py publish
python3 -m http.server --bind 127.0.0.1 --directory publish 8000
```

**Order matters:** version asset URLs **before** hashing fragments. The embed
postprocessor injects its own versioned loader URL before `site-links.js`.
It is idempotent for already-processed pages. To regenerate after source/asset
changes, do a fresh production compilation; don't hand-edit generated fragments.
The deployment workflow runs these steps automatically. Typsite watch mode
itself remains eager; use the postprocessed production output for performance
previews. A `file://` preview cannot fetch fragments.

## Repeat benchmarks / regression checks

Benchmark dependencies are development-only and isolated under `scripts/perf`:

```sh
(cd scripts/perf && npm ci && npx playwright-core install chromium)

python3 -m unittest discover -s .github/scripts -p 'test_*.py'
node scripts/perf/test.mjs publish

# Compare a saved, unsplit old-assets build against the optimized build.
node scripts/perf/benchmark.mjs \
  --before /tmp/oom-before --after publish --mobile --runs 3 \
  --out /tmp/oom-mobile.json

# Unthrottled comparison / optional third-party-inclusive sanity check.
node scripts/perf/benchmark.mjs --before /tmp/oom-before --after publish \
  --out /tmp/oom-unthrottled.json
node scripts/perf/benchmark.mjs --after publish --third-party --pages / \
  --out /tmp/oom-with-external-fonts.json
```

To reproduce a before snapshot, compile the unmodified revision in a separate
checkout with the same Typsite/Typst versions and fonts, then run only
`cache-bust.py`. Avoid comparing an old watch-mode `publish/` containing the
`/_reload` polling script with a production build. `--url https://glomzzz.com`
can inspect a live origin; it is not a substitute for a controlled before/after
pair. Keep browser benchmarks sequential, without other heavy builds/tests.

For a system browser, set `BROWSER_EXECUTABLE=/path/to/chromium`. An existing
Playwright installation can be selected with `PLAYWRIGHT_MODULE=/path/to/playwright-core`.
On NixOS, use a Nix-wrapped system Chromium or an appropriate browser environment;
a downloaded Linux browser may lack shared libraries.

Validation performed:

- Full clean production compilation: passed.
- Five Python unit tests: span/Unicode preservation, nested anchor chains,
  content hashes/references, idempotence, and untouched non-lazy pages.
- Eight Chromium browser checks: zero eager fragment requests, one-fetch/reopen
  behavior, deep/native/legacy anchors, citation + Back navigation, fetch failure
  and retry, no-JS links, lossless SVG/MathML load-all + print restoration, and
  batched/visible-only math sizing (Firefox branch forced for that last check).
- Native **Firefox 156.0** headless smoke check: 76 initial fitted inline formulas,
  115 after loading/opening the article; all 116 MathML elements and 27 SVGs
  present, zero unloaded fragments. [Result](performance/firefox-smoke.json).
  The cached Playwright Firefox failed to launch its content processes in this
  Nix environment, so its full automation suite was not validated here. With a
  working Playwright Firefox install, use `node scripts/perf/test.mjs publish firefox`.
- Safari and physical mobile devices were not tested.

## Next optimization choices

These are follow-up options, **not measured benefits of this patch**:

| Choice | Why consider it | Trade-off |
|---|---|---|
| **WOFF2 for local Latin fonts** | The remaining cold transfer is font-heavy; the current faces are full OTF/TTF files. | Extra build tooling; preserve font licenses and verify italic/semibold rendering. |
| **Self-host/subset CJK and math fonts; defer child-page font CSS** | Reduce render-blocking third-party dependencies and avoid importing every child's typography on the homepage. | More maintenance; verify character coverage, fallback and font updates. |
| External, cached SVG figures | Potential reuse/download savings on math-heavy articles after the initial-tree issue is fixed. | `<img>` SVGs do not preserve internal links, DOM styling or accessibility automatically; not a blind replacement for all formulas. |
| Optional opaque header instead of backdrop blur | Worth profiling separately if scrolling on low-end GPUs still stutters. | Changes appearance; not established as a bottleneck by these load benchmarks. |
| Custom asset cache headers/CDN | Content-addressed files could use long immutable caching on a host supporting it. | Hosting/configuration complexity; does not fix layout or oversized initial HTML by itself. |

The large vendored Noto Sans CJK OTFs are Typst build inputs, not faces referenced
by the site's `fonts.css`. Deleting those files would not by itself save browser
transfer and could change generated SVGs. Optimize **requested** resources, not
just the largest files on disk.

import assert from "node:assert/strict";
import path from "node:path";
import { readFile } from "node:fs/promises";
import { launch, serve, isolate } from "./browser.mjs";

const directory = process.argv[2];
if (!directory) throw new Error("Usage: node test.mjs OPTIMIZED_SITE_DIR [chromium|firefox]");
const server = await serve(directory);
const browser = await launch(process.argv[3] || "chromium");
const errors = [];
let tests = 0;
async function check(name, fn, options = {}) {
    const context = await browser.newContext({ viewport: { width: 1000, height: 800 }, ...options });
    try {
        const page = await context.newPage();
        await isolate(page, server.origin);
        page.on("pageerror", error => errors.push(error.message));
        await fn(page);
        tests++;
        console.log(`PASS ${name}`);
    } finally { await context.close(); }
}
const how = '.embed[data-slug="/how/index"] > details';
async function loaded(page, selector) {
    await page.waitForFunction(selector => {
        const details = document.querySelector(selector);
        return details?.open && !details.dataset.lazySrc;
    }, selector, { timeout: 30_000 });
}
try {
    await check("no initial fragment/index fetch; expand once and cache reopen", async page => {
        const fragments = [];
        page.on("request", r => { if (r.url().includes("/_embeds/")) fragments.push(r.url()); });
        await page.goto(server.origin, { waitUntil: "load" });
        await page.waitForTimeout(100);
        assert.equal(fragments.length, 0);
        assert.ok(await page.locator("*").count() < 1500);
        await page.locator(how + " > summary").click();
        await loaded(page, how);
        assert.equal(fragments.filter(url => url.includes(".html")).length, 1);
        assert.ok(await page.locator(how + " details[data-lazy-src]").count() > 0);
        await page.locator(how + " > summary").click();
        await page.locator(how + " > summary").click();
        await page.waitForTimeout(100);
        assert.equal(fragments.filter(url => url.includes(".html")).length, 1);
    });

    await check("deep heading loads ancestor chain and its own body with native numbering", async page => {
        const id = "how/plt/formal/evaluation-3.1.2.3";
        const selector = '.embed[data-slug="/how/plt/formal/evaluation"] > details';
        await page.goto(server.origin + "/#" + id);
        await loaded(page, selector);
        assert.equal(await page.locator(selector).evaluate(d => d.parentElement.id), id);
        assert.equal(await page.locator(selector).evaluate(d => {
            for (let p = d; p; p = p.parentElement) if (p.localName === "details" && !p.open) return false;
            return true;
        }), true);
        assert.ok(await page.locator(selector + " math").count() > 0);
        assert.ok(await page.locator(".math-text-toggle").count() === 1);
    });

    await check("canonical and legacy statement hashes resolve through unloaded embeds", async page => {
        const selector = '.embed[data-reference-id="definition/one-step-reduction"] > details';
        const source = await readFile(path.join(directory, "statements/definition/one-step-reduction.html"), "utf8");
        const alias = source.match(/data-legacy-reference-id="([^"]+)"/)?.[1];
        assert.ok(alias, "standalone statement declares its historical alias");
        for (const id of ["definition/one-step-reduction", alias]) {
            await page.goto(server.origin + "/#" + id);
            await loaded(page, selector);
        }
    });

    await check("same-page citations hydrate targets and Back restores the source link", async page => {
        await page.goto(server.origin + "/how/plt/formal/evaluation");
        await page.evaluate(() => document.fonts.ready);
        const chosen = await page.evaluate(() => {
            const targets = [...document.querySelectorAll('.embed > details[data-lazy-src]')];
            for (const d of targets) {
                const slug = d.parentElement.dataset.slug;
                const link = [...document.querySelectorAll('.link.local a[href]')].find(a => (a.dataset.pageHref || a.getAttribute("href")) === slug && a.getClientRects().length);
                if (link) { link.dataset.testCitation = "true"; return slug; }
            }
            return null;
        });
        assert.ok(chosen, "real citation to a closed statement exists");
        const link = page.locator('[data-test-citation="true"]');
        await link.scrollIntoViewIfNeeded();
        const top = await link.evaluate(a => a.getBoundingClientRect().top);
        await link.click();
        const selector = `.embed[data-slug="${chosen}"] > details`;
        await loaded(page, selector);
        await page.waitForFunction(() => !!location.hash);
        await page.waitForTimeout(100);
        await page.goBack();
        await page.waitForTimeout(150);
        assert.equal(new URL(page.url()).hash, "");
        const restored = await link.evaluate(a => a.getBoundingClientRect().top);
        assert.ok(Math.abs(restored - top) < 5, `return position ${restored}, expected ${top}`);
    });

    await check("failed fragment retains permalink and retries successfully", async page => {
        let fail = true;
        await page.route("**/_embeds/*.html", route => fail ? route.abort() : route.continue());
        await page.goto(server.origin);
        await page.locator(how + " > summary").click();
        await page.locator(how + " > .lazy-embed-placeholder button").waitFor();
        assert.equal(await page.locator(how + " .lazy-embed-fallback").getAttribute("href"), "/how/index");
        fail = false;
        await page.locator(how + " > .lazy-embed-placeholder button").click();
        await loaded(page, how);
        assert.equal(await page.locator(how + " > .lazy-embed-placeholder").count(), 0);
    });

    await check("without JS, summaries and standalone links remain usable", async page => {
        await page.goto(server.origin);
        await page.locator(how + " > summary").click();
        assert.equal(await page.locator(how).getAttribute("open"), "");
        const fallback = page.locator(how + " .lazy-embed-fallback");
        assert.equal(await fallback.getAttribute("href"), "/how/index");
        await fallback.click();
        await page.waitForURL("**/how/index");
        assert.ok(await page.locator(".embed > details > summary").count() > 0);
    }, { javaScriptEnabled: false });

    await check("load-all preserves SVG/MathML; print opens and restores folds", async page => {
        await page.goto(server.origin + "/how/plt/formal/evaluation");
        await page.locator(".lazy-embed-tools > button").first().click();
        const print = page.locator(".lazy-embed-tools button").last();
        await print.waitFor({ state: "visible" });
        assert.equal(await page.locator("details[data-lazy-src]").count(), 0);
        // Reconstruct expected counts from static fragments, including repeated
        // occurrences. No visual math may disappear during the split/load cycle.
        async function counts(file) {
            const source = await readFile(path.join(directory, file), "utf8");
            const result = { svg: [...source.matchAll(/<svg\b/g)].length, math: [...source.matchAll(/<math\b/g)].length };
            for (const match of source.matchAll(/data-lazy-src="\/([^"]+)"/g)) {
                const child = await counts(match[1]);
                result.svg += child.svg;
                result.math += child.math;
            }
            return result;
        }
        const expected = await counts("how/plt/formal/evaluation.html");
        assert.equal(await page.locator("svg").count(), expected.svg);
        assert.equal(await page.locator("math").count(), expected.math);
        const closed = await page.locator("article details:not([open])").count();
        await page.evaluate(() => {
            window.print = () => {
                window.__printClosed = document.querySelectorAll("article details:not([open])").length;
                window.dispatchEvent(new Event("afterprint"));
            };
        });
        await print.click();
        await page.waitForFunction(() => window.__printClosed === 0);
        assert.equal(await page.locator("article details:not([open])").count(), closed);
    });
    await check("Firefox math-sizing branch skips closed content and batches repeated events", async page => {
        await page.addInitScript(() => {
            const supports = CSS.supports.bind(CSS);
            CSS.supports = (property, value) => property === "-moz-appearance" ? true : supports(property, value);
            const rect = Element.prototype.getBoundingClientRect;
            window.__mathReads = 0;
            window.__hiddenMathReads = 0;
            Element.prototype.getBoundingClientRect = function () {
                if (this.localName === "math") {
                    window.__mathReads++;
                    for (let p = this.parentElement; p; p = p.parentElement) {
                        if (p.localName === "details" && !p.open && !p.querySelector(":scope > summary")?.contains(this)) {
                            window.__hiddenMathReads++;
                            break;
                        }
                    }
                }
                return rect.apply(this, arguments);
            };
        });
        await page.goto(server.origin + "/how/plt/formal/evaluation");
        await page.evaluate(() => document.fonts.ready);
        await page.waitForTimeout(100);
        const measured = await page.evaluate(async () => {
            window.__mathReads = 0;
            const details = document.querySelector(".page-root > details");
            for (let i = 0; i < 100; i++) details.dispatchEvent(new Event("toggle"));
            await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
            return {
                reads: window.__mathReads, hidden: window.__hiddenMathReads,
                formulas: document.querySelectorAll("article math").length,
                fitted: document.querySelectorAll('article span[style*="width:"]').length,
            };
        });
        assert.ok(measured.reads > 0 && measured.reads <= measured.formulas * 2, JSON.stringify(measured));
        assert.equal(measured.hidden, 0);
        assert.ok(measured.fitted > 0);
    });
    assert.deepEqual(errors, []);
    console.log(`${tests} browser checks passed; no uncaught page errors.`);
} finally {
    await browser.close();
    await server.close();
}

import { parseArgs } from "node:util";
import { writeFile } from "node:fs/promises";
import { launch, serve, isolate } from "./browser.mjs";

const { values } = parseArgs({ options: {
    before: { type: "string" }, after: { type: "string" }, url: { type: "string" },
    runs: { type: "string", default: "3" }, pages: { type: "string", default: "/,/how/plt/formal/evaluation" },
    mobile: { type: "boolean", default: false }, "third-party": { type: "boolean", default: false },
    out: { type: "string", default: "benchmark-results.json" },
} });
const runs = Number(values.runs);
if (!Number.isInteger(runs) || runs < 1 || (!values.before && !values.after && !values.url)) {
    throw new Error("Usage: node benchmark.mjs --before DIR --after DIR [--mobile] [--runs 3] [--out FILE]");
}
const servers = [];
const targets = [];
for (const name of ["before", "after"]) {
    if (!values[name]) continue;
    const server = await serve(values[name]);
    servers.push(server);
    targets.push({ name, origin: server.origin });
}
if (values.url) targets.push({ name: "live", origin: new URL(values.url).origin });
let browser;
try {
    browser = await launch();
    const results = [];
    for (let run = 0; run < runs; run++) {
        for (const pathname of values.pages.split(",")) {
            // Alternate order to reduce systematic warm-machine/order bias.
            for (const target of run % 2 ? [...targets].reverse() : targets) {
                const context = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 });
                try {
                    const page = await context.newPage();
                    const cdp = await context.newCDPSession(page);
                    await cdp.send("Performance.enable");
                    await cdp.send("Network.enable");
                    await cdp.send("Network.setCacheDisabled", { cacheDisabled: true });
                    if (values.mobile) {
                        await cdp.send("Emulation.setCPUThrottlingRate", { rate: 4 });
                        await cdp.send("Network.emulateNetworkConditions", {
                            offline: false, latency: 150,
                            downloadThroughput: 1_600_000 / 8, uploadThroughput: 750_000 / 8,
                        });
                    }
                    await isolate(page, target.origin, values["third-party"]);
                    await page.addInitScript(() => {
                        window.__benchmark = { tasks: [], lcp: 0 };
                        new PerformanceObserver(list => list.getEntries().forEach(entry => {
                            window.__benchmark.tasks.push({ start: entry.startTime, duration: entry.duration });
                        })).observe({ type: "longtask", buffered: true });
                        new PerformanceObserver(list => list.getEntries().forEach(entry => {
                            window.__benchmark.lcp = entry.startTime;
                        })).observe({ type: "largest-contentful-paint", buffered: true });
                    });
                    const errors = [];
                    page.on("pageerror", error => errors.push(error.message));
                    await page.goto(target.origin + pathname, { waitUntil: "load", timeout: 120_000 });
                    await page.waitForTimeout(1500);
                    const perf = await page.evaluate(() => {
                        const nav = performance.getEntriesByType("navigation")[0];
                        const resources = performance.getEntriesByType("resource");
                        return {
                            htmlBytes: nav.decodedBodySize, htmlEncodedBytes: nav.encodedBodySize,
                            transferBytes: nav.transferSize + resources.reduce((sum, r) => sum + r.transferSize, 0),
                            requestCount: resources.length + 1,
                            dclMs: nav.domContentLoadedEventEnd, loadMs: nav.loadEventEnd,
                            fcpMs: performance.getEntriesByName("first-contentful-paint")[0]?.startTime ?? null,
                            lcpMs: window.__benchmark.lcp,
                            blockingMs: window.__benchmark.tasks.reduce((sum, t) => sum + Math.max(0, t.duration - 50), 0),
                            maxTaskMs: Math.max(0, ...window.__benchmark.tasks.map(t => t.duration)),
                            elements: document.querySelectorAll("*").length,
                            svg: document.querySelectorAll("svg").length, math: document.querySelectorAll("math").length,
                            initialFragmentRequests: resources.filter(r => /\/_embeds\//.test(r.name)).length,
                        };
                    });
                    const metrics = Object.fromEntries((await cdp.send("Performance.getMetrics")).metrics.map(m => [m.name, m.value]));
                    let expandMs = null;
                    if (pathname === "/") {
                        expandMs = await page.evaluate(async () => {
                            const details = document.querySelector('.embed[data-slug="/how/index"] > details');
                            if (!details) return null;
                            const start = performance.now();
                            details.open = true;
                            await window.OOMLazyEmbeds?.load(details);
                            await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
                            return performance.now() - start;
                        });
                    }
                    const row = {
                        run: run + 1, target: target.name, page: pathname, ...perf,
                        layoutCount: metrics.LayoutCount, layoutMs: metrics.LayoutDuration * 1000,
                        styleMs: metrics.RecalcStyleDuration * 1000, cpuMs: metrics.TaskDuration * 1000,
                        expandMs, errors,
                    };
                    results.push(row);
                    console.log(JSON.stringify(row));
                } finally { await context.close(); }
            }
        }
    }
    const median = numbers => {
        numbers.sort((a, b) => a - b);
        const middle = Math.floor(numbers.length / 2);
        return numbers.length % 2 ? numbers[middle] : (numbers[middle - 1] + numbers[middle]) / 2;
    };
    const summaries = [];
    for (const target of targets) for (const page of values.pages.split(",")) {
        const rows = results.filter(row => row.target === target.name && row.page === page);
        const summary = { target: target.name, page };
        for (const key of Object.keys(rows[0])) {
            if (typeof rows[0][key] === "number" && key !== "run") summary[key] = median(rows.map(row => row[key]));
        }
        summaries.push(summary);
    }
    const report = {
        browser: browser.version(), timestamp: new Date().toISOString(), runs,
        profile: values.mobile ? "390x844, 4x CPU, 1.6 Mbps down / 0.75 Mbps up, 150 ms latency" : "390x844, unthrottled CPU/network",
        thirdParty: values["third-party"], observation: "load + 1500ms; blocking = sum(max(0, longTaskDuration - 50ms)), not Lighthouse TBT",
        summaries, results,
    };
    await writeFile(values.out, JSON.stringify(report, null, 2) + "\n");
    console.table(summaries.map(row => Object.fromEntries(Object.entries(row).map(([key, value]) => [key, typeof value === "number" ? Math.round(value) : value]))));
    if (results.some(row => row.errors.length)) process.exitCode = 1;
} finally {
    await browser?.close();
    await Promise.all(servers.map(server => server.close()));
}

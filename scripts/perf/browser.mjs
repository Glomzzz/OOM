import http from "node:http";
import { readFile, stat } from "node:fs/promises";
import path from "node:path";
import { gzipSync } from "node:zlib";
import { createRequire } from "node:module";

export async function launch(browserName = "chromium") {
    const require = createRequire(import.meta.url);
    let playwright;
    try {
        playwright = require(process.env.PLAYWRIGHT_MODULE || "playwright-core");
    } catch {
        throw new Error("Install benchmark dependencies: cd scripts/perf && npm ci && npx playwright-core install chromium");
    }
    return playwright[browserName].launch({
        headless: true,
        ...(process.env.BROWSER_EXECUTABLE ? { executablePath: process.env.BROWSER_EXECUTABLE } : {}),
    });
}

export async function serve(directory) {
    const root = path.resolve(directory);
    const cache = new Map();
    const requests = [];
    const types = {
        ".html": "text/html; charset=utf-8", ".json": "application/json",
        ".js": "application/javascript", ".css": "text/css", ".svg": "image/svg+xml",
        ".png": "image/png", ".jpg": "image/jpeg", ".ico": "image/x-icon",
        ".ttf": "font/ttf", ".otf": "font/otf", ".woff2": "font/woff2",
    };
    const server = http.createServer(async (req, res) => {
        try {
            const pathname = decodeURIComponent(new URL(req.url, "http://localhost").pathname);
            requests.push(pathname);
            if (!cache.has(pathname)) {
                let file = path.resolve(root, "." + pathname);
                if (file !== root && !file.startsWith(root + path.sep)) throw new Error("Outside root");
                let info;
                try { info = await stat(file); } catch {
                    file += ".html";
                    info = await stat(file);
                }
                if (info.isDirectory()) file = path.join(file, "index.html");
                const data = gzipSync(await readFile(file));
                cache.set(pathname, { data, type: types[path.extname(file)] || "application/octet-stream" });
            }
            const { data, type } = cache.get(pathname);
            res.writeHead(200, {
                "Content-Type": type, "Content-Encoding": "gzip",
                "Content-Length": data.length, "Cache-Control": "no-store",
            });
            res.end(data);
        } catch {
            res.writeHead(404);
            res.end("Not found");
        }
    });
    await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
    return {
        origin: `http://127.0.0.1:${server.address().port}`,
        requests,
        close: () => new Promise(resolve => server.close(resolve)),
    };
}

export async function isolate(page, origin, allowThirdParty = false) {
    if (!allowThirdParty) await page.route("**/*", route => {
        const url = new URL(route.request().url());
        // Empty successful CSS avoids network variability without console errors.
        if (url.origin !== origin) return route.fulfill({ status: 200, contentType: "text/css", body: "" });
        return route.continue();
    });
}

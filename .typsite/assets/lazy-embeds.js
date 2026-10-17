/* Closed transclusions are static fragments. No framework or server needed.
 * Summaries and standalone permalinks work without this enhancement.
 */
(() => {
    "use strict";
    const article = document.querySelector("article[data-lazy-index]");
    if (!article) return;
    const pending = new WeakMap();
    const byKey = new Map();
    let indexPromise;

    function register(root) {
        root.querySelectorAll("details[data-lazy-key]").forEach(details => {
            byKey.set(details.dataset.lazyKey, details);
        });
    }
    register(article);

    function localURL(value) {
        const url = new URL(value, location.href);
        if (url.origin !== location.origin) throw new Error("Cross-origin embed URL");
        return url.href;
    }

    function load(details) {
        if (!details?.dataset.lazySrc) return Promise.resolve();
        if (pending.has(details)) return pending.get(details);
        const placeholder = details.querySelector(":scope > .lazy-embed-placeholder");
        const status = placeholder?.querySelector(".lazy-embed-status");
        placeholder?.querySelector("button")?.remove();
        if (status) status.textContent = "正在加载… ";
        details.setAttribute("aria-busy", "true");
        const promise = (async () => {
            try {
                const response = await fetch(localURL(details.dataset.lazySrc));
                if (!response.ok) throw new Error(`Embed HTTP ${response.status}`);
                const template = document.createElement("template");
                template.innerHTML = await response.text();
                if (!placeholder) throw new Error("Missing embed placeholder");
                placeholder.replaceWith(template.content);
                delete details.dataset.lazySrc;
                register(details);
                // Consumers index just the new subtree, not the entire book.
                document.dispatchEvent(new CustomEvent("oom:embeds-loaded", { detail: { root: details } }));
            } catch (error) {
                if (status) status.textContent = "内容加载失败。 ";
                if (placeholder && !placeholder.querySelector("button")) {
                    const retry = document.createElement("button");
                    retry.type = "button";
                    retry.textContent = "重试";
                    retry.addEventListener("click", () => { void load(details).catch(() => {}); });
                    placeholder.prepend(retry);
                }
                throw error;
            } finally {
                details.removeAttribute("aria-busy");
                pending.delete(details);
            }
        })();
        pending.set(details, promise);
        return promise;
    }

    async function index() {
        if (!indexPromise) {
            indexPromise = (async () => {
                const response = await fetch(localURL(article.dataset.lazyIndex));
                if (!response.ok) throw new Error(`Embed index HTTP ${response.status}`);
                const data = await response.json();
                if (data.version !== 1) throw new Error("Unsupported embed index");
                return data;
            })().catch(error => { indexPromise = null; throw error; });
        }
        return indexPromise;
    }

    // Repeated statements belong to the nearest chapter, just as with eager
    // transclusions. The deepest available placeholder represents its subtree.
    function nearest(records, source) {
        if (!records?.length) return null;
        const owner = record => document.getElementById(record.anchor)
            || [...record.chain].reverse().map(key => byKey.get(key)).find(Boolean);
        for (let scope = source; scope; scope = scope.parentElement) {
            const record = records.find(record => {
                const node = owner(record);
                return node && scope.contains(node);
            });
            if (record) return record;
        }
        return records[0];
    }

    async function reveal(records, source) {
        const record = nearest(records, source);
        if (!record) return null;
        for (const key of record.chain) {
            const details = byKey.get(key);
            if (!details) throw new Error(`Missing embed ${key}`);
            details.open = true;
            await load(details);
        }
        return document.getElementById(record.anchor);
    }

    async function revealId(id, source = article) {
        if (document.getElementById(id)) return document.getElementById(id);
        const data = await index();
        // Historical statement aliases may have a positional prefix.
        const alias = id.replace(/^(?:\d+-)+(?=(?:fm|pl)-)/, "");
        return reveal(data.anchors[id] || data.anchors[alias], source);
    }

    async function revealSlug(slug, source = article) {
        const data = await index();
        return reveal(data.slugs[slug], source);
    }

    document.addEventListener("toggle", event => {
        const details = event.target;
        if (details.localName === "details" && details.open && details.dataset.lazySrc) {
            void load(details).catch(() => {}); // Accessible error + permalink stay in the details.
        }
    }, true);

    // Async work cannot finish in beforeprint, and the browser cannot find
    // text that has not been downloaded. Make whole-book loading explicit.
    const tools = document.createElement("p");
    tools.className = "lazy-embed-tools";
    const all = document.createElement("button");
    all.type = "button";
    all.textContent = "加载全文（查找／打印）";
    const message = document.createElement("span");
    message.setAttribute("role", "status");
    const print = document.createElement("button");
    print.type = "button";
    print.textContent = "打印全文";
    print.hidden = true;
    tools.append(all, document.createTextNode(" "), message, document.createTextNode(" "), print);
    (article.querySelector(".page-footer") || article).append(tools);

    async function loadAll() {
        // Bound network concurrency; newly inserted fragments can add children.
        while (true) {
            const batch = [...article.querySelectorAll("details[data-lazy-src]")].slice(0, 4);
            if (!batch.length) return;
            await Promise.all(batch.map(load));
        }
    }
    all.addEventListener("click", async () => {
        all.disabled = true;
        message.textContent = "正在加载全文…";
        try {
            await loadAll();
            all.hidden = true;
            print.hidden = false;
            message.textContent = "全文已加载，可以使用浏览器查找。";
        } catch {
            message.textContent = "部分内容加载失败，请重试或打开独立页面。";
        } finally {
            all.disabled = false;
        }
    });
    print.addEventListener("click", async () => {
        const closed = [...article.querySelectorAll("details:not([open])")];
        closed.forEach(details => { details.open = true; });
        const restore = () => closed.forEach(details => { details.open = false; });
        window.addEventListener("afterprint", restore, { once: true });
        await document.fonts?.ready;
        await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
        window.print();
    });

    window.OOMLazyEmbeds = { load, revealId, revealSlug, loadAll };
})();

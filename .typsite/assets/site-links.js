/* Progressive enhancement for transcluded pages.
 * Citations always retain working standalone URLs. Eager and lazy embeds
 * share the same native Typsite anchors, numbering and history behavior.
 */
(() => {
    "use strict";
    const article = document.querySelector("#grid-wrapper > article");
    if (!article) return;
    const pageRoot = article.querySelector(".page-root");
    const lazy = window.OOMLazyEmbeds;
    const anchorAliases = new Map();
    const positions = new WeakMap();
    const numbered = new WeakSet();
    const indexed = new WeakSet();
    const bySlug = new Map();
    const byReferenceId = new Map();

    document.querySelectorAll("#toc .heading-numbering[id]").forEach(node => node.removeAttribute("id"));

    function nativeNumbering(section) {
        return section?.querySelector(":scope > details > summary > .heading-numbering, :scope > details > summary > header > .heading-numbering");
    }
    function append(map, key, value) {
        if (!map.has(key)) map.set(key, []);
        if (!map.get(key).includes(value)) map.get(key).push(value);
    }
    function canonicalPath(value) {
        const url = new URL(value, location.href);
        if (url.origin !== location.origin) return null;
        return url.pathname.replace(/\.html$/, "").replace(/\/$/, "").replace(/\/index$/, "") || "/";
    }
    function nearest(candidates, source) {
        if (!candidates?.length) return null;
        for (let scope = source; scope; scope = scope.parentElement) {
            const target = candidates.find(candidate => scope.contains(candidate));
            if (target) return target;
        }
        return candidates[0];
    }

    function indexContent(root) {
        // Repair cached parent prefixes once per section. Recording positions
        // even before statements arrive keeps numbering stable across loads.
        for (const section of root.querySelectorAll("section.block")) {
            if (numbered.has(section)) continue;
            numbered.add(section);
            const numbering = nativeNumbering(section);
            const match = numbering?.id.match(/^(.*)-(\d+(?:\.\d+)*)$/);
            if (!match) continue;
            let parent = section.parentElement.closest("section.block");
            while (parent && !nativeNumbering(parent)) parent = parent.parentElement.closest("section.block");
            const parentNumbering = nativeNumbering(parent);
            const local = match[2].split(".").at(-1);
            const position = [...(positions.get(parent) || []), local];
            positions.set(section, position);
            const oldId = numbering.id;
            numbering.id = match[1] + "-" + position.join(".");
            if (/^\d+(?:\.\d+)*$/.test(numbering.textContent.trim())) {
                const prefix = parentNumbering?.textContent.trim();
                numbering.textContent = (prefix && /^\d+(?:\.\d+)*$/.test(prefix) ? prefix + "." : "") + local;
            }
            if (oldId !== numbering.id) append(anchorAliases, oldId, section.matches(".embed") ? section : numbering);
        }

        for (const section of root.querySelectorAll(".page-root, .embed[data-slug]")) {
            if (indexed.has(section)) continue;
            indexed.add(section);
            const numbering = nativeNumbering(section);
            if (section.matches(".embed") && numbering) {
                section.id = numbering.id;
                numbering.removeAttribute("id");
            }
            if (!section.id) continue;
            append(bySlug, canonicalPath(section.dataset.slug), section);
            for (const id of [section.dataset.referenceId, section.dataset.legacyReferenceId].filter(Boolean)) {
                append(byReferenceId, id, section);
            }
        }
        // A statement's summary can be indexed before its anchor body arrives.
        for (const anchor of root.querySelectorAll(".statement-anchor [id]")) {
            const section = anchor.closest(".embed, .page-root");
            if (!section) continue;
            const ids = [section.dataset.referenceId, section.dataset.legacyReferenceId].filter(Boolean);
            const id = ids.find(id => anchor.id === id || anchor.id.endsWith("-" + id));
            if (!id) continue;
            const position = positions.get(section) || [];
            const oldId = anchor.id;
            anchor.id = (position.length ? position.join("-") + "-" : "") + id;
            if (oldId !== anchor.id) append(anchorAliases, oldId, section);
        }

        for (const link of root.querySelectorAll('a[href^="#"]')) {
            let id;
            try { id = decodeURIComponent(link.getAttribute("href").slice(1)); } catch { continue; }
            const alias = nearest(anchorAliases.get(id), link);
            if (alias) link.setAttribute("href", "#" + alias.id);
        }
        for (const link of document.querySelectorAll('#toc a[href^="#"]')) {
            let id;
            try { id = decodeURIComponent(link.getAttribute("href").slice(1)); } catch { continue; }
            const target = document.getElementById(id) || nearest(anchorAliases.get(id), link);
            if (!target) continue;
            const numbering = target.matches(".heading-numbering") ? target : nativeNumbering(target);
            const label = link.querySelector(".heading-numbering");
            if (numbering && label) label.textContent = numbering.textContent;
            const taxon = target.matches(".embed, .page-root")
                ? target.querySelector(":scope > details > summary > header > .taxon, :scope > details > summary > header > h1 > .taxon")
                : null;
            if (taxon?.dataset.taxon && !link.querySelector(".toc-taxon")) {
                const prefix = taxon.cloneNode(true);
                prefix.classList.add("toc-taxon");
                prefix.textContent = taxon.dataset.taxon;
                link.prepend(prefix, document.createTextNode(" "));
            }
        }
        for (const link of root.querySelectorAll(".link.local a[href]")) {
            const href = link.dataset.pageHref || link.getAttribute("href");
            if (!href || href.startsWith("#")) continue;
            const url = new URL(href, location.href);
            if (url.hash || url.search) continue;
            const target = nearest(bySlug.get(canonicalPath(href)), link);
            if (target) {
                link.dataset.pageHref = href;
                link.href = "#" + target.id;
            }
        }
    }
    indexContent(article);
    document.addEventListener("oom:embeds-loaded", event => indexContent(event.detail.root));

    function hashValue() {
        try { return decodeURIComponent(location.hash.slice(1)); }
        catch { return location.hash.slice(1); }
    }
    function findHash(id, source = pageRoot || article) {
        const alias = id.replace(/^(?:\d+-)+(?=(?:fm|pl)-)/, "");
        return document.getElementById(id) || nearest(anchorAliases.get(id), source)
            || nearest(byReferenceId.get(alias), source);
    }
    async function openTarget(target, scroll = true) {
        const loads = [];
        for (let node = target; node; node = node.parentElement) {
            if (node instanceof HTMLDetailsElement) {
                node.open = true;
                if (lazy) loads.push(lazy.load(node));
            }
        }
        if (target.matches(".embed, .page-root")) {
            const details = target.querySelector(":scope > details");
            if (details) {
                details.open = true;
                if (lazy) loads.push(lazy.load(details));
            }
        }
        await Promise.all(loads);
        if (scroll) requestAnimationFrame(() => target.scrollIntoView({ block: "start" }));
    }
    let navigation = 0;
    async function followHash() {
        const token = ++navigation;
        const id = hashValue();
        if (!id) return;
        try {
            let target = findHash(id);
            if (!target && lazy) target = await lazy.revealId(id) || findHash(id);
            if (token !== navigation) return;
            if (target) await openTarget(target, !history.state?.ret);
        } catch (error) {
            console.warn("Could not open embedded anchor:", error);
        }
    }

    // Keep a stable handle to the source link: inserting an earlier fragment
    // changes the old all-links index, but must not break Back's return point.
    let returnId = 0;
    const allLinks = () => Array.from(document.querySelectorAll("a[href]"));
    function rememberLink(link, top) {
        if (!link.id) {
            let id;
            do { id = "oom-return-link-" + ++returnId; } while (document.getElementById(id));
            link.id = id;
        }
        const ret = { id: link.id, index: allLinks().indexOf(link), top };
        history.replaceState({ ...(history.state || {}), ret }, "");
        history.scrollRestoration = "manual";
    }
    function restoreReturn() {
        const ret = history.state?.ret;
        history.scrollRestoration = ret ? "manual" : "auto";
        if (!ret) return;
        const link = document.getElementById(ret.id) || allLinks()[ret.index];
        if (!link) return;
        for (let node = link; node; node = node.parentElement) {
            if (node instanceof HTMLDetailsElement) node.open = true;
        }
        const align = () => window.scrollBy(0, link.getBoundingClientRect().top - ret.top);
        align();
        requestAnimationFrame(align);
    }
    async function navigate(target, link, returnTop) {
        const hash = "#" + encodeURI(target.id);
        if (hash !== location.hash) {
            rememberLink(link, returnTop);
            history.pushState(null, "", hash);
        }
        await openTarget(target);
    }

    document.addEventListener("click", event => {
        if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        const link = event.target.closest?.("a[href]");
        if (!link || link.hasAttribute("download") || (link.target && link.target !== "_self")) return;
        const url = new URL(link.dataset.pageHref || link.getAttribute("href"), location.href);
        if (url.origin !== location.origin) return;
        const citation = !!link.closest(".link.local") && !url.hash && !url.search;
        const returnTop = link.getBoundingClientRect().top;
        if (citation && (lazy || bySlug.has(canonicalPath(url.href)))) {
            event.preventDefault();
            void (async () => {
                try {
                    const target = (lazy && await lazy.revealSlug(canonicalPath(url.href), link))
                        || nearest(bySlug.get(canonicalPath(url.href)), link);
                    if (target) await navigate(target, link, returnTop);
                    else location.assign(url.href);
                } catch {
                    // A standalone page remains usable if the fragment/index fails.
                    location.assign(url.href);
                }
            })();
            return;
        }
        if (canonicalPath(url.href) !== canonicalPath(location.href) || !url.hash) return;
        let id;
        try { id = decodeURIComponent(url.hash.slice(1)); } catch { return; }
        const existing = findHash(id, link);
        if (!existing && !lazy) return;
        event.preventDefault();
        void (async () => {
            try {
                const target = existing || await lazy.revealId(id, link) || findHash(id, link);
                if (target) await navigate(target, link, returnTop);
                else if (location.hash !== url.hash) location.hash = url.hash;
            } catch (error) {
                console.warn("Could not follow embedded link:", error);
            }
        })();
    });

    const tocToggle = document.getElementById("toc-toggle");
    if (tocToggle) {
        const closeToc = () => { tocToggle.checked = false; };
        document.addEventListener("click", event => {
            if (!tocToggle.checked) return;
            const target = event.target;
            if (target.closest?.("#toc a") || target.closest?.("#grid-wrapper > article")) closeToc();
        });
        document.addEventListener("keydown", event => {
            if (event.key === "Escape" && tocToggle.checked) {
                closeToc();
                tocToggle.focus();
            }
        });
    }
    window.addEventListener("popstate", restoreReturn);
    window.addEventListener("hashchange", () => {
        if (!history.state?.ret) history.scrollRestoration = "auto";
        void followHash();
    });
    window.addEventListener("pageshow", () => { void followHash(); });
    void followHash();
    restoreReturn();
})();

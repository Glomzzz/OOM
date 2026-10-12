/* Progressive enhancement for transcluded pages.
 * Every citation has a working static URL. When the target is also embedded
 * in this page, use its native typsite anchor and open all enclosing details.
 * Never invent counters or fetch other pages to resolve a reference.
 */
(() => {
    "use strict";

    const article = document.querySelector("#grid-wrapper > article");
    if (!article) return;

    const pageRoot = article.querySelector(".page-root");
    const sections = [...article.querySelectorAll(".page-root, .embed[data-slug]")];

    // The numbering template is also used in the TOC. Keep its anchor only
    // in the article, so getElementById cannot land on a duplicate in the nav.
    document.querySelectorAll("#toc .heading-numbering[id]").forEach(node => {
        node.removeAttribute("id");
    });

    function nativeNumbering(section) {
        return section?.querySelector(":scope > details > summary > .heading-numbering, :scope > details > summary > header > .heading-numbering");
    }

    const anchorAliases = new Map();
    const positions = new WeakMap();
    const hasStatementEmbeds = !!article.querySelector('.embed[data-slug^="/statements/"]');

    // Typsite 0.1.7 caches already-composed child HTML during hot reload.
    // A partially updated nested embed can retain a standalone/previous
    // parent's prefix. Reattach its *native local index* to its actual parent;
    // no counter is incremented here. Clean builds already have these values.
    for (const section of article.querySelectorAll("section.block")) {
        // Include ordinary parent headings too, so shared statements work in
        // any article, not only in the formalization series.
        if (!hasStatementEmbeds && !section.closest('.page-root[data-slug^="/how/plt/formal"], .embed[data-slug^="/how/plt/formal"], .page-root[data-slug^="/statements/"]')) continue;
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
        const text = numbering.textContent.trim();
        if (/^\d+(?:\.\d+)*$/.test(text)) {
            const prefix = parentNumbering?.textContent.trim();
            numbering.textContent = (prefix && /^\d+(?:\.\d+)*$/.test(prefix) ? prefix + "." : "") + local;
        }
        if (oldId !== numbering.id) {
            if (!anchorAliases.has(oldId)) anchorAliases.set(oldId, []);
            anchorAliases.get(oldId).push(section.matches(".embed") ? section : numbering);
        }
    }

    function canonicalPath(value) {
        const url = new URL(value, location.href);
        if (url.origin !== location.origin) return null;
        const path = url.pathname.replace(/\.html$/, "").replace(/\/$/, "");
        return path || "/";
    }

    const bySlug = new Map();
    const byReferenceId = new Map();

    for (const section of sections) {
        const numbering = nativeNumbering(section);
        if (section.matches(".embed") && numbering) {
            // Native heading anchors are positional and unique even when the
            // same article is embedded more than once.
            section.id = numbering.id;
            numbering.removeAttribute("id");
        }
        if (!section.id) continue;

        const slug = canonicalPath(section.dataset.slug);
        if (!bySlug.has(slug)) bySlug.set(slug, []);
        bySlug.get(slug).push(section);

        const referenceId = section.dataset.referenceId;
        if (referenceId) {
            const ids = [referenceId, section.dataset.legacyReferenceId].filter(Boolean);
            const anchors = [...section.querySelectorAll(":scope > details > .statement-anchor [id]")];
            const position = positions.get(section) || [];
            for (const id of ids) {
                const anchor = anchors.find(node => node.id === id || node.id.endsWith("-" + id));
                if (anchor) {
                    const oldId = anchor.id;
                    anchor.id = (position.length ? position.join("-") + "-" : "") + id;
                    if (oldId !== anchor.id) {
                        if (!anchorAliases.has(oldId)) anchorAliases.set(oldId, []);
                        anchorAliases.get(oldId).push(section);
                    }
                }
                if (!byReferenceId.has(id)) byReferenceId.set(id, []);
                byReferenceId.get(id).push(section);
            }
        }
    }

    // For repeated transclusions, pick the occurrence with the nearest common
    // ancestor, preferring the source's own chapter over a sibling chapter.
    function nearest(candidates, source) {
        if (!candidates?.length) return null;
        for (let scope = source; scope; scope = scope.parentElement) {
            const target = candidates.find(candidate => scope.contains(candidate));
            if (target) return target;
        }
        return candidates[0];
    }

    for (const link of document.querySelectorAll('a[href^="#"]')) {
        let id;
        try { id = decodeURIComponent(link.hash.slice(1)); } catch { continue; }
        const alias = nearest(anchorAliases.get(id), link);
        const target = alias || document.getElementById(id);
        if (alias) link.href = "#" + alias.id;
        if (target && link.closest("#toc")) {
            const numbering = target.matches(".heading-numbering") ? target : nativeNumbering(target);
            const label = link.querySelector(".heading-numbering");
            if (numbering && label) label.textContent = numbering.textContent;
            // Copy the target's own English taxon before the native counter,
            // never an ancestor's taxon or a page-local number in a citation.
            const taxon = target.matches(".embed, .page-root")
                ? target.querySelector(":scope > details > summary > header > .taxon, :scope > details > summary > header > h1 > .taxon")
                : null;
            if (taxon?.dataset.taxon) {
                const prefix = taxon.cloneNode(true);
                prefix.classList.add("toc-taxon");
                prefix.textContent = taxon.dataset.taxon;
                link.prepend(prefix, document.createTextNode(" "));
            }
        }
    }

    for (const link of article.querySelectorAll(".link.local a[href]")) {
        const href = link.getAttribute("href");
        if (!href || href.startsWith("#")) continue;
        const url = new URL(href, location.href);
        if (url.hash || url.search) continue;
        const candidates = bySlug.get(canonicalPath(href));
        const target = nearest(candidates, link);
        if (target) {
            link.dataset.pageHref = href;
            link.href = "#" + target.id;
        }
    }

    function hashValue() {
        try {
            return decodeURIComponent(location.hash.slice(1));
        } catch {
            return location.hash.slice(1);
        }
    }

    function openTarget(target, scroll = true) {
        for (let node = target; node; node = node.parentElement) {
            if (node instanceof HTMLDetailsElement) node.open = true;
        }
        if (target.matches(".embed, .page-root")) {
            const details = target.querySelector(":scope > details");
            if (details) details.open = true;
        }
        if (scroll) requestAnimationFrame(() => target.scrollIntoView({ block: "start" }));
    }

    function followHash() {
        const hash = hashValue();
        if (!hash) return;
        let target = document.getElementById(hash) || nearest(anchorAliases.get(hash), pageRoot || article);
        if (!target) {
            // Keep old fm-* / pl-* anchors while canonical IDs are now the
            // full category/name keys. Aliases come from the statement page.
            const referenceId = hash.replace(/^(?:\d+-)+(?=(?:fm|pl)-)/, "");
            target = nearest(byReferenceId.get(referenceId), pageRoot || article);
        }
        // Back/forward to an entry that remembers a clicked link: leave the
        // scroll position to restoreReturn() instead of jumping to the hash.
        if (target) openTarget(target, !history.state?.ret);
    }

    // Same-page links push a history entry. Remember which link was clicked and
    // where it sat in the viewport, so Back can put that link back in place even
    // when opening the target expanded content above it.
    const allLinks = () => Array.from(document.querySelectorAll("a[href]"));

    function rememberLink(link) {
        const index = allLinks().indexOf(link);
        if (index < 0) return;
        const ret = { index, top: link.getBoundingClientRect().top };
        history.replaceState({ ...(history.state || {}), ret }, "");
        history.scrollRestoration = "manual";
    }

    function restoreReturn() {
        const ret = history.state?.ret;
        history.scrollRestoration = ret ? "manual" : "auto";
        if (!ret) return;
        const link = allLinks()[ret.index];
        if (!link) return;
        for (let node = link; node; node = node.parentElement) {
            if (node instanceof HTMLDetailsElement) node.open = true;
        }
        const align = () => window.scrollBy(0, link.getBoundingClientRect().top - ret.top);
        align();
        requestAnimationFrame(align);
    }

    // Hashchange does not fire when a reader clicks the current hash again.
    // Also handle TOC links and legacy goto links inside closed supplements.
    document.addEventListener("click", event => {
        if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        const link = event.target.closest?.("a[href]");
        if (!link || link.hasAttribute("download") || (link.target && link.target !== "_self")) return;
        const url = new URL(link.href, location.href);
        if (canonicalPath(url.href) !== canonicalPath(location.href) || !url.hash) return;
        let id;
        try { id = decodeURIComponent(url.hash.slice(1)); } catch { return; }
        const target = document.getElementById(id) || nearest(byReferenceId.get(id), link);
        if (!target) return;
        if (url.hash !== location.hash) rememberLink(link);
        openTarget(target);
    });

    // The table of contents is an overlay drawer: close it after picking an
    // entry, on Escape, or when the reader clicks the article behind it.
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
        // New entries inherit "manual" from the page we left; reset them.
        if (!history.state?.ret) history.scrollRestoration = "auto";
        followHash();
    });
    window.addEventListener("pageshow", followHash);
    followHash();
    restoreReturn();
})();

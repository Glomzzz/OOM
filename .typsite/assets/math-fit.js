/* Firefox overestimates the intrinsic width of some inline MathML wrappers.
 * Other engines do not need this workaround. Never lay out the closed book
 * just to measure hidden formulas; discover new formulas as embeds arrive.
 */
(() => {
    "use strict";
    if (!CSS.supports("-moz-appearance", "none")) return;
    const article = document.querySelector("#grid-wrapper > article");
    if (!article) return;
    const pairs = new Map();
    const pending = new Set();
    let frame = 0;

    function inClosedBody(node) {
        for (let parent = node.parentElement; parent && parent !== article; parent = parent.parentElement) {
            if (parent.localName !== "details" || parent.open) continue;
            const summary = parent.querySelector(":scope > summary");
            if (!summary?.contains(node)) return true;
        }
        return false;
    }
    function schedule(list) {
        for (const pair of list) if (!inClosedBody(pair.math)) pending.add(pair);
        if (!pending.size || frame) return;
        frame = requestAnimationFrame(() => {
            frame = 0;
            const list = [...pending].filter(pair => pair.math.isConnected && !inClosedBody(pair.math));
            pending.clear();
            // One read phase and one write phase, including toggle/resize/font
            // events arriving together. Unchanged widths do not trigger reflow.
            const widths = list.map(({ math }) => math.getBoundingClientRect().width);
            list.forEach(({ wrapper }, i) => {
                if (widths[i] <= 0) return;
                const width = `${Math.ceil(widths[i])}px`;
                if (wrapper.style.width !== width) wrapper.style.width = width;
            });
        });
    }
    const observer = "ResizeObserver" in window ? new ResizeObserver(entries => {
        schedule(entries.map(entry => pairs.get(entry.target)).filter(Boolean));
    }) : null;

    function discover(root) {
        const visible = [];
        for (const math of root.querySelectorAll('math:not([display="block"])')) {
            const wrapper = math.parentElement;
            if (wrapper?.localName !== "span" || inClosedBody(math)) continue;
            if (!pairs.has(wrapper)) {
                pairs.set(wrapper, { math, wrapper });
                observer?.observe(wrapper);
            }
            visible.push(pairs.get(wrapper));
        }
        schedule(visible);
    }
    discover(article);
    document.addEventListener("toggle", event => {
        if (event.target.localName === "details" && event.target.open) discover(event.target);
    }, true);
    document.addEventListener("oom:embeds-loaded", event => discover(event.detail.root));
    document.fonts?.ready.then(() => schedule(pairs.values()));
    document.fonts?.addEventListener("loadingdone", () => schedule(pairs.values()));
})();

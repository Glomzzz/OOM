/* Fit the scroll wrapper of an inline formula to the formula itself.
 *
 * In Firefox the wrapper (see schemas/page.css) is an inline-block whose
 * width comes from the intrinsic width estimate of its MathML. For formulas
 * with stretchy operators such as ( ) [ ] { } | / that estimate is wider than
 * the width the <math> element finally lays out at, which leaves empty space
 * on the right of the formula. Setting stretchy="false" on the operators
 * removes the surplus, which is how it was traced. CSS alone (fit-content,
 * flex, grid, contain) did not fix it, so copy the laid-out width instead.
 *
 * Without JS the wrapper keeps its slightly generous width.
 */
(() => {
    "use strict";

    const article = document.querySelector("#grid-wrapper > article");
    if (!article) return;

    const pairs = [...article.querySelectorAll('math:not([display="block"])')]
        .map(math => ({ math, wrapper: math.parentElement }))
        .filter(({ wrapper }) => wrapper?.localName === "span");
    if (pairs.length === 0) return;

    function fit(list) {
        // Measure first, write after, so a pass causes a single reflow.
        const widths = list.map(({ math }) => math.getBoundingClientRect().width);
        list.forEach(({ wrapper }, i) => {
            // A formula without a box (closed <details>) measures 0; leave it
            // on auto until it is shown.
            wrapper.style.width = widths[i] > 0 ? `${Math.ceil(widths[i])}px` : "";
        });
    }

    fit(pairs);

    // A formula in a closed <details> or an inline fold gets its box only when
    // opened, and its wrapper is what changes from 0x0 to a real size.
    if ("ResizeObserver" in window) {
        const byWrapper = new Map(pairs.map(pair => [pair.wrapper, pair]));
        const observer = new ResizeObserver(entries => {
            fit(entries.map(entry => byWrapper.get(entry.target)).filter(Boolean));
        });
        pairs.forEach(({ wrapper }) => observer.observe(wrapper));
    }

    // The wrapper of a formula in a closed <details> keeps a stale size, so
    // the observer above may not fire when it opens. Refit those explicitly.
    document.addEventListener("toggle", event => {
        const details = event.target;
        if (details.localName !== "details" || !details.open) return;
        fit(pairs.filter(({ wrapper }) => details.contains(wrapper)));
    }, true);

    // Math fonts arrive late and change the width of the formula.
    document.fonts?.ready.then(() => fit(pairs));
    document.fonts?.addEventListener("loadingdone", () => fit(pairs));
})();

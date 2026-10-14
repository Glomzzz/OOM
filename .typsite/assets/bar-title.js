/* Make the page title look as if it climbs from the article into the top bar.
 * The bar clips its title, so the title is kept exactly where the article's own
 * heading is, one to one, until it reaches the bar's centre line and settles.
 * Below the bar the clipped title is out of sight; as the heading passes under
 * the bar, the title shows the same pixels the bar is covering.
 */
(() => {
    "use strict";

    const bar = document.querySelector("body > .header");
    if (!bar) return;
    const heading = document.querySelector(
        "#grid-wrapper > article .page-root > details > summary > .top-header > h1"
    );
    // No heading to follow: keep the title visible.
    if (!heading) {
        bar.style.setProperty("--bar-title-shift", "0px");
        return;
    }

    function update() {
        const barBox = bar.getBoundingClientRect();
        const box = heading.getBoundingClientRect();
        // Follow the heading's first line, even if the heading wraps.
        const line = parseFloat(getComputedStyle(heading).lineHeight) || box.height;
        const headingCentre = box.top + Math.min(line, box.height) / 2;
        const barCentre = barBox.top + barBox.height / 2;
        const shift = Math.max(0, headingCentre - barCentre);
        bar.style.setProperty("--bar-title-shift", shift.toFixed(1) + "px");
    }

    addEventListener("scroll", update, { passive: true });
    addEventListener("resize", update);
    addEventListener("load", update);
    if ("ResizeObserver" in window) new ResizeObserver(update).observe(document.body);
    update();
})();

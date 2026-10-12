/* The text alternatives are static HTML and remain readable without JS.
 * This optional control lets sighted readers select/copy SVG math as text.
 */
(() => {
    "use strict";
    const article = document.querySelector("#grid-wrapper > article");
    if (!article?.querySelector(".math-fallback")) return;
    const wrapper = article.parentElement;
    const toggle = document.createElement("button");
    toggle.type = "button";
    toggle.className = "math-text-toggle";
    toggle.lang = "zh-CN";
    toggle.textContent = "𝑓";
    const update = visible => {
        const action = visible ? "显示公式排版" : "显示公式文本";
        toggle.title = action;
        toggle.setAttribute("aria-label", action);
        toggle.setAttribute("aria-pressed", String(visible));
    };
    update(false);
    toggle.addEventListener("click", () => {
        update(article.classList.toggle("math-text-visible"));
    });
    const sidebarButton = wrapper.querySelector(":scope > .toc-button");
    if (sidebarButton) sidebarButton.after(toggle);
    else wrapper.append(toggle);
})();

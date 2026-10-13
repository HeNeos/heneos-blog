const items = [
  { href: "/heneos-blog", shortcut: "ha", keyChar: "a" },
  { href: "/heneos-blog/blog", shortcut: "hb", keyChar: "b" },
  { href: "/heneos-blog/about", shortcut: "hc", keyChar: "c" },
  { href: "/heneos-blog/devlog", shortcut: "hd", keyChar: "d" },
];

let lastKey = "";
let lastKeyTime = 0;

window.addEventListener("keydown", (event) => {
  const target = event.target;
  if (
    target.tagName === "INPUT" ||
    target.tagName === "TEXTAREA" ||
    target.isContentEditable
  ) {
    return;
  }

  const currentTime = Date.now();
  const character = event.key.toLowerCase();
  const sequenceIsActive = currentTime - lastKeyTime < 1000;

  if (lastKey === "h" && sequenceIsActive) {
    const item = items.find((candidate) => candidate.keyChar === character);
    if (item) {
      window.location.href = item.href;
      lastKey = "";
      return;
    }
  }

  lastKey = character === "h" ? "h" : "";
  lastKeyTime = currentTime;
});

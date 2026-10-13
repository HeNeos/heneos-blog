# HeNeos blog

A static blog generator written in [Gleam](https://gleam.io), targeting
JavaScript. Markdown posts are rendered with the unified/remark/rehype
ecosystem (GFM, LaTeX via KaTeX, syntax highlighting) through a thin
JavaScript FFI shim.

## Requirements

- [Gleam](https://gleam.io) 1.18+
- Node.js 20+

## Commands

```sh
npm ci          # install the JavaScript rendering dependencies
npm run build   # gleam run: generate the site into out/
npm run dev     # build, then serve out/ at http://localhost:3000/heneos-blog/
npm run serve   # serve an already-built out/
```

## Structure

- `src/heneos_blog.gleam` — page templates and site generation
- `src/markdown.mjs` — markdown rendering FFI (react-markdown + plugins)
- `src/node.mjs` — filesystem and date formatting FFI
- `static/` — static assets copied into the generated site
- `content/posts/` — markdown posts (frontmatter + body)

Output is written to `out/` and deployed to GitHub Pages by
`.github/workflows/deploy.yml`.

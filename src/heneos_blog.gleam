import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/string

const base_path = "/heneos-blog"

pub type Post {
  Post(
    slug: String,
    title: String,
    date: String,
    description: String,
    tags: List(String),
    content: String,
  )
}

type DevlogEntry {
  DevlogEntry(
    id: String,
    title: String,
    url: String,
    description: String,
    added_at: String,
    read_at: Option(String),
  )
}

@external(javascript, "./node.mjs", "list_directory")
fn list_directory(directory: String) -> String

@external(javascript, "./node.mjs", "read_file")
fn read_file(file_path: String) -> String

@external(javascript, "./node.mjs", "write_file")
fn write_file(file_path: String, contents: String) -> Nil

@external(javascript, "./node.mjs", "reset_output")
fn reset_output(directory: String) -> Nil

@external(javascript, "./node.mjs", "copy_file")
fn copy_file(source_path: String, destination_path: String) -> Nil

@external(javascript, "./node.mjs", "copy_directory")
fn copy_directory(source_path: String, destination_path: String) -> Nil

@external(javascript, "./node.mjs", "format_date")
fn format_date(date_value: String) -> String

@external(javascript, "./node.mjs", "format_short_date")
fn format_short_date(date_value: String) -> String

@external(javascript, "./markdown.mjs", "render_markdown")
fn render_markdown(content: String) -> String

pub fn main() -> Nil {
  build_site()
  io.println("Static site written to out/")
}

fn build_site() -> Nil {
  let posts = read_posts()
  let ascii_art = read_file("static/ascii-art.html")
  reset_output("out")
  copy_file("static/styles.css", "out/styles.css")
  copy_file("static/theme.css", "out/theme.css")
  copy_file("node_modules/katex/dist/katex.min.css", "out/katex.min.css")
  copy_file(
    "node_modules/highlight.js/styles/github-dark.css",
    "out/github-dark.css",
  )
  copy_directory("node_modules/katex/dist/fonts", "out/fonts")
  copy_file("static/navigation.js", "out/navigation.js")
  copy_file("static/enhance.js", "out/enhance.js")
  write_file("out/.nojekyll", "")
  write_file("out/index.html", render_home_page(posts, ascii_art))
  write_file("out/blog.html", render_blog_page(posts))
  write_file("out/about.html", render_about_page())
  write_file("out/devlog.html", render_devlog_page())
  write_file("out/404.html", render_not_found_page())
  write_post_pages(posts)
}

fn read_posts() -> List(Post) {
  list_directory("content/posts")
  |> string.split(on: "\n")
  |> list.filter(keeping: is_markdown_file)
  |> list.map(with: post_from_file)
  |> list.sort(by: compare_posts)
}

fn is_markdown_file(file_name: String) -> Bool {
  string.ends_with(file_name, ".md")
}

fn post_from_file(file_name: String) -> Post {
  let slug = string.drop_end(from: file_name, up_to: 3)
  let raw_content = read_file("content/posts/" <> file_name)
  let sections = string.split(raw_content, on: "\n---\n")
  post_from_sections(slug, sections)
}

fn post_from_sections(slug: String, sections: List(String)) -> Post {
  case sections {
    [frontmatter, content, ..] -> {
      let fields = string.split(frontmatter, on: "\n")
      Post(
        slug: slug,
        title: metadata_value(fields, "title") |> unquote,
        date: metadata_value(fields, "date") |> unquote,
        description: metadata_value(fields, "description") |> unquote,
        tags: metadata_value(fields, "tags") |> parse_tags,
        content: content,
      )
    }
    _ -> Post(slug, "", "", "", [], "")
  }
}

fn metadata_value(lines: List(String), field_name: String) -> String {
  case lines {
    [line, ..remaining_lines] ->
      metadata_value_from_line(line, field_name, remaining_lines)
    [] -> ""
  }
}

fn metadata_value_from_line(
  line: String,
  field_name: String,
  remaining_lines: List(String),
) -> String {
  let prefix = field_name <> ":"
  case string.starts_with(line, prefix) {
    True ->
      string.drop_start(from: line, up_to: string.length(prefix))
      |> string.trim
    False -> metadata_value(remaining_lines, field_name)
  }
}

fn unquote(value: String) -> String {
  let value = string.trim(value)
  case string.starts_with(value, "\"") {
    True ->
      string.drop_start(from: string.drop_end(from: value, up_to: 1), up_to: 1)
    False -> unquote_single_quoted(value)
  }
}

fn unquote_single_quoted(value: String) -> String {
  case string.starts_with(value, "'") {
    True ->
      string.drop_start(from: string.drop_end(from: value, up_to: 1), up_to: 1)
    False -> value
  }
}

fn parse_tags(value: String) -> List(String) {
  let value = string.trim(value)
  case string.length(value) < 2 {
    True -> []
    False -> parse_tag_values(value)
  }
}

fn parse_tag_values(value: String) -> List(String) {
  let tag_values =
    string.drop_start(from: string.drop_end(from: value, up_to: 1), up_to: 1)
  case string.trim(tag_values) == "" {
    True -> []
    False -> string.split(tag_values, on: ",") |> list.map(unquote)
  }
}

fn compare_posts(first: Post, second: Post) -> Order {
  string.compare(second.date, first.date)
}

fn write_post_pages(posts: List(Post)) -> Nil {
  case posts {
    [post, ..remaining_posts] -> {
      write_file("out/blog/" <> post.slug <> ".html", render_post_page(post))
      write_post_pages(remaining_posts)
    }
    [] -> Nil
  }
}

// ---------------------------------------------------------------------------
// Ranking / tag helpers
// ---------------------------------------------------------------------------

fn formatted_counter(index: Int) -> String {
  let value = int.to_string(index)
  case index < 10 {
    True -> "0" <> value
    False -> value
  }
}

fn render_posts(
  posts: List(Post),
  starting_index: Int,
  render: fn(Post, Int) -> String,
) -> String {
  posts
  |> list.index_map(fn(post, offset) { render(post, starting_index + offset) })
  |> string.concat
}

fn render_tags(tags: List(String)) -> String {
  tags |> list.map(with: render_tag) |> string.concat
}

fn render_tag(tag: String) -> String {
  "<span class=\"tag\">#" <> escape_html(tag) <> "</span>"
}

// ---------------------------------------------------------------------------
// Page renderers
// ---------------------------------------------------------------------------

fn render_home_page(posts: List(Post), ascii_art: String) -> String {
  render_document(
    title: "HeNeos blog",
    description: "A programming blog with Markdown, LaTeX, and code snippets",
    active_path: "/",
    highlight: False,
    content: home_content(posts, ascii_art),
  )
}

fn home_content(posts: List(Post), ascii_art: String) -> String {
  "<div class=\"wrap\">"
  <> "<section class=\"hero fade-up\">"
  <> "<div class=\"terminal\">"
  <> "<div class=\"terminal-bar\">"
  <> "<span class=\"dot\"></span>"
  <> "<span class=\"dot\"></span>"
  <> "<span class=\"dot\"></span>"
  <> "<span class=\"terminal-title\">heneos@nixos: ~</span>"
  <> "</div>"
  <> "<div class=\"terminal-body\">"
  <> "<div class=\"term-grid\">"
  <> "<span class=\"term-key\">name</span>"
  <> "<span class=\"term-val\">Josue H. <span class=\"dim\">// HeNeos</span></span>"
  <> "<span class=\"term-key\">role</span>"
  <> "<span class=\"term-val\">Cloud Solutions Architect</span>"
  <> "<span class=\"term-key\">focus</span>"
  <> "<span class=\"term-val\">distributed systems <span class=\"sep\">·</span> cybersecurity</span>"
  <> "<span class=\"term-key\">langs</span>"
  <> "<span class=\"term-val\">Rust <span class=\"sep\">·</span> Idris <span class=\"sep\">·</span> Nix</span>"
  <> "<span class=\"term-key\">now</span>"
  <> "<span class=\"term-val\">functional programming, type-driven design</span>"
  <> "</div>"
  <> "<div class=\"term-prompt\"><span class=\"sig\">&#10095;</span><span class=\"cursor\"></span></div>"
  <> "</div>"
  <> "</div>"
  <> "<div class=\"hero-actions\">"
  <> "<a class=\"btn btn-primary\" href=\""
  <> base_path
  <> "/blog\">read blog "
  <> icon_arrow()
  <> "</a>"
  <> "<a class=\"btn btn-ghost\" href=\""
  <> base_path
  <> "/about\">about</a>"
  <> "</div>"
  <> "</section>"
  <> "<section class=\"section\" data-reveal>"
  <> "<div class=\"panels\">"
  <> "<div class=\"panel\">"
  <> "<h3>Currently learning</h3>"
  <> "<ul class=\"list-index\">"
  <> "<li><span class=\"n\">01</span><span>Idris</span></li>"
  <> "<li><span class=\"n\">02</span><span>Nix</span></li>"
  <> "<li><span class=\"n\">03</span><span>Rust</span></li>"
  <> "</ul>"
  <> "</div>"
  <> "<div class=\"panel\">"
  <> "<h3>Currently reading</h3>"
  <> "<ul class=\"list-index\">"
  <> "<li><span class=\"n\">01</span><span>Designing Data-Intensive Applications</span></li>"
  <> "<li><span class=\"n\">02</span><span>Zero Trust Networks</span></li>"
  <> "<li><span class=\"n\">03</span><span>Real-World Cryptography</span></li>"
  <> "</ul>"
  <> "</div>"
  <> "</div>"
  <> "</section>"
  <> "<section class=\"section\" data-reveal>"
  <> "<div class=\"section-head\">"
  <> "<h2>Recent posts</h2>"
  <> "<a class=\"link-more\" href=\""
  <> base_path
  <> "/blog\">View all &rarr;</a>"
  <> "</div>"
  <> "<div class=\"post-list\">"
  <> render_posts(posts |> list.take(3), 1, render_blog_post)
  <> "</div>"
  <> "</section>"
  <> "<div class=\"ascii-wrap\" data-reveal>"
  <> ascii_art
  <> "</div>"
  <> "</div>"
}

fn render_blog_page(posts: List(Post)) -> String {
  render_document(
    title: "HeNeos blog",
    description: "A programming blog with Markdown, LaTeX, and code snippets",
    active_path: "/blog",
    highlight: False,
    content: "<div class=\"wrap-narrow\">"
      <> "<h1 class=\"page-title\">Blog posts</h1>"
      <> "<p class=\"page-sub\">Notes on cloud architecture, distributed systems, competitive programming, and everything in between.</p>"
      <> "<div class=\"post-list\">"
      <> render_posts(posts, 1, render_blog_post)
      <> "</div>"
      <> "</div>",
  )
}

fn render_blog_post(post: Post, index: Int) -> String {
  "<a class=\"post-card\" data-reveal href=\""
  <> post_href(post)
  <> "\"><div class=\"index\">"
  <> formatted_counter(index)
  <> "</div><div class=\"post-main\">"
  <> "<h2 class=\"post-title\">"
  <> escape_html(post.title)
  <> "</h2>"
  <> "<div class=\"date\">"
  <> format_date(post.date)
  <> "</div>"
  <> "<div class=\"desc\">"
  <> escape_html(post.description)
  <> "</div>"
  <> "<div class=\"tags\">"
  <> render_tags(post.tags)
  <> "</div>"
  <> "</div></a>"
}

fn render_post_page(post: Post) -> String {
  render_document(
    title: post.title <> " | HeNeos blog",
    description: post.description,
    active_path: "",
    highlight: True,
    content: "<div class=\"wrap-narrow\">"
      <> "<a class=\"back-link\" href=\""
      <> base_path
      <> "/blog\">&larr; All posts</a>"
      <> "<article>"
      <> "<header class=\"article-head\">"
      <> "<h1 class=\"article-title\">"
      <> escape_html(post.title)
      <> "</h1>"
      <> "<div class=\"article-meta\">"
      <> "<span class=\"date\">"
      <> format_date(post.date)
      <> "</span>"
      <> "<span class=\"tags\">"
      <> render_tags(post.tags)
      <> "</span>"
      <> "</div>"
      <> "</header>"
      <> "<div class=\"article-body\">"
      <> render_markdown(post.content)
      <> "</div>"
      <> "</article>"
      <> "</div>",
  )
}

fn render_about_page() -> String {
  render_document(
    title: "About | HeNeos blog",
    description: "Learn more about the author of this blog",
    active_path: "/about",
    highlight: False,
    content: "<div class=\"wrap-narrow\">"
      <> "<h1 class=\"page-title\">About</h1>"
      <> "<div class=\"prose\">"
      <> "<p>Welcome to my blog. I&#x27;m an engineer with interests in distributed systems, cloud security, algorithms &amp; data structures, and technology in general.</p>"
      <> "<p>I used to be a competitive programmer in my college days and still have fun doing that in my barely free time. I&#x27;m currently the top 2 solver of my country in Project Euler.</p>"
      <> "<h2>Tech stack</h2>"
      <> "<p>I work across a range of technologies, including:</p>"
      <> "<div class=\"stack\">"
      <> render_chip("Python")
      <> render_chip("JavaScript / TypeScript")
      <> render_chip("AWS")
      <> render_chip("Kubernetes")
      <> render_chip("And more")
      <> "</div>"
      <> "<h2>Connect</h2>"
      <> "<p>Feel free to reach out on social media or check out my work:</p>"
      <> "<div class=\"social-list\">"
      <> "<a href=\"https://github.com/HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\">"
      <> icon_github()
      <> "<span>GitHub</span></a>"
      <> "<a href=\"https://x.com/_HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\">"
      <> icon_x()
      <> "<span>X / Twitter</span></a>"
      <> "<a href=\"https://www.linkedin.com/in/heneos\" target=\"_blank\" rel=\"noopener noreferrer\">"
      <> icon_linkedin()
      <> "<span>LinkedIn</span></a>"
      <> "<a href=\"mailto:he.neos@outlook.com\">"
      <> icon_mail()
      <> "<span>Email</span></a>"
      <> "</div>"
      <> "</div>"
      <> "<div class=\"hero-actions\">"
      <> "<a class=\"btn btn-primary\" href=\""
      <> base_path
      <> "/blog\">Read the blog"
      <> icon_arrow()
      <> "</a>"
      <> "</div>"
      <> "</div>",
  )
}

fn render_chip(label: String) -> String {
  "<span class=\"tag\">" <> escape_html(label) <> "</span>"
}

fn render_devlog_page() -> String {
  render_document(
    title: "DevLog | HeNeos blog",
    description: "My personal devlog",
    active_path: "/devlog",
    highlight: False,
    content: "<div class=\"wrap-narrow\">"
      <> "<h1 class=\"page-title\">Dev log</h1>"
      <> "<p class=\"page-sub\">A running list of papers, posts, and tools I&#x27;m working through.</p>"
      <> "<div class=\"devlog-list\">"
      <> render_devlog_entries(devlog_entries())
      <> "</div>"
      <> "</div>",
  )
}

fn render_devlog_entries(entries: List(DevlogEntry)) -> String {
  case entries {
    [entry, ..remaining_entries] ->
      render_devlog_entry(entry) <> render_devlog_entries(remaining_entries)
    [] -> ""
  }
}

fn render_devlog_entry(entry: DevlogEntry) -> String {
  "<div class=\"devlog-item\">"
  <> "<div class=\"devlog-main\">"
  <> "<a class=\"devlog-title\" href=\""
  <> escape_html(entry.url)
  <> "\" target=\"_blank\" rel=\"noopener noreferrer\">"
  <> escape_html(entry.title)
  <> "</a>"
  <> "<p class=\"devlog-desc\">"
  <> escape_html(entry.description)
  <> "</p>"
  <> "<div class=\"devlog-meta\">Added "
  <> escape_html(format_short_date(entry.added_at))
  <> render_read_date(entry.read_at)
  <> "</div>"
  <> "</div>"
  <> "<span class=\""
  <> devlog_status_class(entry.read_at)
  <> "\">"
  <> devlog_status_text(entry.read_at)
  <> "</span>"
  <> "</div>"
}

fn render_read_date(read_at: Option(String)) -> String {
  case read_at {
    Some(date) -> " &middot; Read " <> escape_html(format_short_date(date))
    None -> ""
  }
}

fn devlog_status_class(read_at: Option(String)) -> String {
  case read_at {
    Some(_) -> "chip chip-read"
    None -> "chip"
  }
}

fn devlog_status_text(read_at: Option(String)) -> String {
  case read_at {
    Some(_) -> "Read"
    None -> "Unread"
  }
}

fn render_not_found_page() -> String {
  render_document(
    title: "404: This page could not be found.",
    description: "A programming blog with Markdown, LaTeX, and code snippets",
    active_path: "",
    highlight: False,
    content: "<div class=\"wrap empty-state\">"
      <> "<span class=\"empty-code\">404</span>"
      <> "<p>This page could not be found.</p>"
      <> "<a class=\"btn btn-ghost\" href=\""
      <> base_path
      <> "/\">Back home</a>"
      <> "</div>",
  )
}

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

fn post_href(post: Post) -> String {
  base_path <> "/blog/" <> escape_html(post.slug)
}

const favicon = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='7' fill='%230a0c11'/%3E%3Crect x='1' y='1' width='30' height='30' rx='6.5' fill='none' stroke='%233b82f6' stroke-opacity='.5'/%3E%3Ctext x='16' y='22' font-family='monospace' font-size='15' font-weight='700' fill='%233b82f6' text-anchor='middle'%3EH%3C/text%3E%3C/svg%3E"

const fonts_href = "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&family=VT323&display=swap"

fn render_document(
  title title: String,
  description description: String,
  active_path active_path: String,
  highlight highlight: Bool,
  content content: String,
) -> String {
  "<!DOCTYPE html>"
  <> "<html lang=\"en\">"
  <> "<head>"
  <> "<meta charset=\"utf-8\">"
  <> "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
  <> "<title>"
  <> escape_html(title)
  <> "</title>"
  <> "<meta name=\"description\" content=\""
  <> escape_html(description)
  <> "\">"
  <> "<meta name=\"color-scheme\" content=\"dark\">"
  <> "<meta name=\"theme-color\" content=\"#0a0c11\">"
  <> "<meta property=\"og:type\" content=\"website\">"
  <> "<meta property=\"og:title\" content=\""
  <> escape_html(title)
  <> "\">"
  <> "<meta property=\"og:description\" content=\""
  <> escape_html(description)
  <> "\">"
  <> "<meta property=\"og:site_name\" content=\"HeNeos blog\">"
  <> "<meta name=\"twitter:card\" content=\"summary\">"
  <> "<link rel=\"icon\" href=\""
  <> favicon
  <> "\">"
  <> "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">"
  <> "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>"
  <> "<link rel=\"stylesheet\" href=\""
  <> fonts_href
  <> "\">"
  <> "<link rel=\"stylesheet\" href=\""
  <> base_path
  <> "/styles.css\">"
  <> "<link rel=\"stylesheet\" href=\""
  <> base_path
  <> "/theme.css\">"
  <> "<link rel=\"stylesheet\" href=\""
  <> base_path
  <> "/katex.min.css\">"
  <> case highlight {
    True ->
      "<link rel=\"stylesheet\" href=\"" <> base_path <> "/github-dark.css\">"
    False -> ""
  }
  <> "<script>document.documentElement.classList.add(\"js\")</script>"
  <> "</head>"
  <> "<body>"
  <> "<div class=\"progress\" aria-hidden=\"true\"><span></span></div>"
  <> render_header(active_path)
  <> "<main>"
  <> content
  <> "</main>"
  <> render_footer()
  <> "<script src=\""
  <> base_path
  <> "/navigation.js\" defer></script>"
  <> "<script src=\""
  <> base_path
  <> "/enhance.js\" defer></script>"
  <> "</body>"
  <> "</html>"
}

fn render_header(active_path: String) -> String {
  "<header class=\"site-header\">"
  <> "<div class=\"wrap header-inner\">"
  <> "<a class=\"brand\" href=\""
  <> base_path
  <> "\">"
  <> "<span class=\"brand-name\">HeNeos</span>"
  <> "<span class=\"brand-tag\">Josue H. &middot; Cloud Solutions Architect</span>"
  <> "</a>"
  <> "<div class=\"header-links\">"
  <> render_navigation(active_path)
  <> "<div class=\"socials\">"
  <> icon_link("https://github.com/HeNeos", "GitHub", True, icon_github())
  <> icon_link(
    "https://www.linkedin.com/in/heneos",
    "LinkedIn",
    True,
    icon_linkedin(),
  )
  <> icon_link("mailto:he.neos@outlook.com", "Email", False, icon_mail())
  <> "</div>"
  <> "</div>"
  <> "</div>"
  <> "</header>"
}

fn render_navigation(active_path: String) -> String {
  "<nav class=\"nav\" aria-label=\"Primary\">"
  <> render_navigation_item("Home", "/", "ha", active_path == "/")
  <> render_navigation_item("Blog", "/blog", "hb", active_path == "/blog")
  <> render_navigation_item("About", "/about", "hc", active_path == "/about")
  <> render_navigation_item(
    "Dev Log",
    "/devlog",
    "hd",
    active_path == "/devlog",
  )
  <> "</nav>"
}

fn render_navigation_item(
  label: String,
  path: String,
  shortcut: String,
  is_active: Bool,
) -> String {
  "<a class=\"nav-link\" href=\""
  <> navigation_href(path)
  <> "\""
  <> case is_active {
    True -> " aria-current=\"page\""
    False -> ""
  }
  <> "><span>"
  <> label
  <> "</span><span class=\"key\">"
  <> shortcut
  <> "</span></a>"
}

fn navigation_href(path: String) -> String {
  case path {
    "/" -> base_path
    _ -> base_path <> path
  }
}

fn icon_link(
  href: String,
  label: String,
  external: Bool,
  icon: String,
) -> String {
  "<a class=\"icon-link\" href=\""
  <> escape_html(href)
  <> "\" aria-label=\""
  <> escape_html(label)
  <> "\" title=\""
  <> escape_html(label)
  <> "\""
  <> case external {
    True -> " target=\"_blank\" rel=\"noopener noreferrer\""
    False -> ""
  }
  <> ">"
  <> icon
  <> "</a>"
}

fn icon_github() -> String {
  "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4\"/><path d=\"M9 18c-4.51 2-5-2-7-2\"/></svg>"
}

fn icon_linkedin() -> String {
  "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z\"/><rect width=\"4\" height=\"12\" x=\"2\" y=\"9\"/><circle cx=\"4\" cy=\"4\" r=\"2\"/></svg>"
}

fn icon_mail() -> String {
  "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><rect width=\"20\" height=\"16\" x=\"2\" y=\"4\" rx=\"2\"/><path d=\"m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7\"/></svg>"
}

fn icon_x() -> String {
  "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\" aria-hidden=\"true\"><path d=\"M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z\"/></svg>"
}

fn icon_arrow() -> String {
  "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M5 12h14\"/><path d=\"m12 5 7 7-7 7\"/></svg>"
}

fn render_footer() -> String {
  "<footer class=\"site-footer\">"
  <> "<div class=\"wrap\">"
  <> "<div class=\"footer-grid\">"
  <> "<div class=\"footer-col\">"
  <> "<span class=\"brand-name\">HeNeos</span>"
  <> "<p class=\"footer-note\">Writing about distributed systems, cloud architecture, cybersecurity, and algorithms.</p>"
  <> "</div>"
  <> "<div class=\"footer-col\">"
  <> "<h4>Elsewhere</h4>"
  <> "<div class=\"footer-links\">"
  <> footer_link("https://github.com/HeNeos", "GitHub")
  <> footer_link("https://x.com/_HeNeos", "X")
  <> footer_link("https://codeforces.com/profile/HeNeos", "Codeforces")
  <> footer_link("mailto:he.neos@outlook.com", "Email")
  <> "</div>"
  <> "</div>"
  <> "<div class=\"footer-col\">"
  <> "<h4>Project Euler</h4>"
  <> "<div class=\"footer-links\">"
  <> "<a href=\"https://projecteuler.net/profile/HeNeos.png\" target=\"_blank\" rel=\"noopener noreferrer\">"
  <> "<img src=\"https://projecteuler.net/profile/HeNeos.png\" alt=\"Project Euler profile for HeNeos\" loading=\"lazy\">"
  <> "</a>"
  <> "</div>"
  <> "</div>"
  <> "</div>"
  <> "<div class=\"footer-bottom\"><span>&copy; HeNeos</span><span>Built with Gleam</span></div>"
  <> "</div>"
  <> "</footer>"
}

fn footer_link(href: String, label: String) -> String {
  "<a href=\""
  <> escape_html(href)
  <> "\" target=\"_blank\" rel=\"noopener noreferrer\">"
  <> escape_html(label)
  <> "</a>"
}

fn escape_html(value: String) -> String {
  value
  |> string.replace(each: "&", with: "&amp;")
  |> string.replace(each: "<", with: "&lt;")
  |> string.replace(each: ">", with: "&gt;")
  |> string.replace(each: "\"", with: "&quot;")
  |> string.replace(each: "'", with: "&#x27;")
}

fn devlog_entries() -> List(DevlogEntry) {
  [
    DevlogEntry(
      "genuine-sieve",
      "Genuine Sieve",
      "https://www.cs.hmc.edu/~oneill/papers/Sieve-JFP.pdf",
      "A raw implementation of Eratosthenes' Sieve in functional programming.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "lambda-calculus-ocaml",
      "Learn Lambda Calculus in 10 minutes with OCaml",
      "https://chshersh.com/blog/2024-02-05-learn-lambda-calculus-in-10-minutes-with-ocaml.html",
      "A fast introduction to lambda calculus using OCaml.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "pragmatic-category-theory",
      "Pragmatic Category Theory",
      "https://chshersh.com/blog/2024-07-30-pragmatic-category-theory-part-01.html",
      "A practical introduction to category theory concepts.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "rego-101",
      "Rego 101: Introduction to Rego",
      "https://snyk.io/blog/introduction-to-rego/",
      "Learn the basics of Rego and policy-based authorization.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "knapsack-convolution",
      "[Tutorial] Knapsack, Subset Sum and the (max,+) Convolution",
      "https://codeforces.com/blog/entry/98663",
      "Understanding DP optimizations and (max,+) convolution in competitive programming.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "ruliology-lambdas",
      "The ruliology of lambdas",
      "https://writings.stephenwolfram.com/2025/09/the-ruliology-of-lambdas/",
      "Stephen Wolfram explores lambda calculus through the lens of ruliology.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "numbat",
      "Numbat",
      "https://github.com/sharkdp/numbat",
      "Numbat is a statically typed programming language for scientific computations with first class support for physical dimensions and units.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "mojo",
      "Mojo",
      "https://www.modular.com/mojo",
      "Mojo is a programming language that unifies high-level AI development with low-level systems programming. Write once, deploy everywhere - from CPUs to GPUs",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "pytoolz",
      "Pytoolz",
      "https://toolz.readthedocs.io/en/latest/",
      "A set of utility functions for iterators, functions, and dictionaries.",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "jujutsu-for-busy-devs",
      "Jujutsu for busy devs",
      "https://maddie.wtf/posts/2025-07-21-jujutsu-for-busy-devs",
      "Jujutsu (jj) is a version control system with a significantly simplified mental model and command-line interface compared to Git, without sacrificing expressibility or power",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "confused-deputy",
      "The confused deputy problem",
      "docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html",
      "The confused deputy problem is a security issue where an entity that doesn't have permission to perform an action can coerce a more-privileged entity",
      "2025-10-29",
      None,
    ),
    DevlogEntry(
      "diggydb",
      "DiggyDB",
      "https://github.com/njbmartin/diggydb-nodejs",
      "A lightweight Node.js key-value store with a simple file-based storage engine.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "anubis",
      "Anubis",
      "https://anubis.techaro.lol/",
      "A small and elegant static site generator focused on simplicity and clean design.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "kd-tree",
      "k-d tree",
      "https://en.wikipedia.org/wiki/K-d_tree",
      "A multidimensional binary search tree used for nearest-neighbor search and spatial indexing.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "curse-of-knowing",
      "The Curse of Knowing How, or; Fixing Everything",
      "https://notashelf.dev/posts/curse-of-knowing",
      "A reflection on the cognitive trap of always wanting to fix systems once you understand them deeply.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-mastodon",
      "grhkm — Mastodon",
      "https://mathstodon.xyz/@grhkm",
      "grhkm's primary Mastodon profile, focused on math and cryptography insights.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-old-mastodon",
      "grhkm — Old Mastodon",
      "https://infosec.exchange/@grhkm",
      "grhkm's older Mastodon profile with infosec-related posts and discussions.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-baby-rsa",
      "BabyRSA — Bauhinia CTF 2023 analysis",
      "https://connor-mccartney.github.io/cryptography/small-roots/babyRSA-Bauhinia-CTF-2023",
      "A detailed walk-through of solving the BabyRSA challenge using small-roots techniques.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-timing-attacks",
      "Breaking perfect security with timing attacks",
      "https://www.youtube.com/watch?v=OC5D6DD1-_w",
      "A great video illustrating how subtle timing differences can completely break cryptographic systems.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-codeforces",
      "grhkm — Codeforces blog",
      "https://codeforces.com/blog/grhkm",
      "Competitive programming posts, problem breakdowns, and math-heavy algorithm insights by grhkm.",
      "2025-11-01",
      None,
    ),
    DevlogEntry(
      "grhkm-cryptohack",
      "grhkm — CryptoHack",
      "https://cryptohack.org/user/grhkm/",
      "grhkm's CryptoHack profile with their progress on modern cryptography challenges.",
      "2025-11-01",
      None,
    ),
  ]
}

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
  copy_file("node_modules/katex/dist/katex.min.css", "out/katex.min.css")
  copy_file(
    "node_modules/highlight.js/styles/github-dark.css",
    "out/github-dark.css",
  )
  copy_directory("node_modules/katex/dist/fonts", "out/fonts")
  copy_file("static/navigation.js", "out/navigation.js")
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
  "<span class=\"inline-block bg-zinc-800 text-zinc-300 px-2 py-1 text-xs rounded-sm\">#"
  <> escape_html(tag)
  <> "</span>"
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
  "<div class=\"max-w-5xl mx-auto\">"
  <> "<section class=\"mb-6 p-4 border border-zinc-800 rounded-sm bg-zinc-900/60\">"
  <> "<div class=\"line-numbers\">"
  <> "<div class=\"flex items-start\"><span class=\"text-zinc-500 select-none\"></span><h1 class=\"text-xl font-mono gradient-text\">Hi, I&#x27;m HeNeos</h1></div>"
  <> "<div class=\"flex items-start\"><span class=\"text-zinc-500 select-none\"></span><p class=\"text-sm font-mono text-zinc-300\">I&#x27;m a Cloud Solutions Architect.</p></div>"
  <> "<div class=\"flex items-start\"><span class=\"text-zinc-500 select-none\"></span><p class=\"text-sm font-mono text-zinc-300\">I primarily use <span class=\"font-bold\">Python</span>, <span class=\"font-bold\">TypeScript</span>, <span class=\"font-bold\">AWS</span>, and <span class=\"font-bold\">Kubernetes</span>.</p></div>"
  <> "<div class=\"flex items-start\"><span class=\"text-zinc-500 select-none\"></span><p class=\"text-sm font-mono text-zinc-300\">I&#x27;m interested on distributed systems, cloud, cyber security, algorithms and data structures.</p></div>"
  <> "<div class=\"flex gap-2 mt-1\">"
  <> "<a class=\"bg-zinc-800 hover:bg-blue-400 hover:text-zinc-900 text-zinc-100 px-4 py-2 rounded-sm transition-colors text-sm\" href=\""
  <> base_path
  <> "/blog\">Read Blog</a>"
  <> "<a class=\"border border-zinc-700 hover:border-blue-400 text-zinc-300 hover:text-blue-400 px-4 py-2 rounded-sm transition-colors text-sm\" href=\""
  <> base_path
  <> "/about\">About Me</a>"
  <> "</div>"
  <> "</div>"
  <> "</section>"
  <> "<section class=\"flex flex-col md:flex-row gap-4\">"
  <> "<div class=\"p-2 flex-1\">"
  <> "<h2 class=\"text-2xl font-raleway\">Currently learning</h2>"
  <> "<div class=\"line-numbers\">"
  <> "<div class=\"flex items-start my-2\"><span class=\"text-zinc-500 mr-1 select-none\"></span><p class=\"text-zinc-300\">Rust</p></div>"
  <> "<div class=\"flex items-start my-2\"><span class=\"text-zinc-500 mr-1 select-none\"></span><p class=\"text-zinc-300\">OCaml</p></div>"
  <> "</div>"
  <> "</div>"
  <> "<div class=\"p-2 flex-1\">"
  <> "<h2 class=\"text-2xl font-raleway\">Currently reading</h2>"
  <> "<div class=\"line-numbers\">"
  <> "<div class=\"flex items-start my-2\"><span class=\"text-zinc-500 mr-1 select-none\"></span><p class=\"text-zinc-300\">Designing Data-Intensive Applications</p></div>"
  <> "<div class=\"flex items-start my-2\"><span class=\"text-zinc-500 mr-1 select-none\"></span><p class=\"text-zinc-300\">Zero Trust Networks</p></div>"
  <> "<div class=\"flex items-start my-2\"><span class=\"text-zinc-500 mr-1 select-none\"></span><p class=\"text-zinc-300\">Real-World Cryptography</p></div>"
  <> "</div>"
  <> "</div>"
  <> "</section>"
  <> "<section>"
  <> "<div class=\"flex justify-between items-center mb-8 border-b border-zinc-800 pb-4\"><h2 class=\"text-4xl font-raleway\">Recent Posts</h2><a class=\"text-zinc-500 hover:text-accent animated-underline\" href=\""
  <> base_path
  <> "/blog\">View all →</a></div>"
  <> "<div class=\"space-y-6\">"
  <> render_posts(posts |> list.take(3), 1, render_home_post)
  <> "</div>"
  <> "</section>"
  <> ascii_art
  <> "</div>"
}

fn render_home_post(post: Post, index: Int) -> String {
  "<article class=\"border border-zinc-800 rounded-sm p-6 card-hover bg-card/40 backdrop-blur-sm\">"
  <> "<div class=\"flex items-start\">"
  <> "<div class=\"text-zinc-500 font-mono mr-4 pt-1 select-none\">"
  <> formatted_counter(index)
  <> "</div>"
  <> "<div class=\"flex-1\">"
  <> "<a href=\""
  <> post_href(post)
  <> "\"><h3 class=\"text-2xl font-raleway mb-2 hover:text-blue-400 transition-colors\">"
  <> escape_html(post.title)
  <> "</h3></a>"
  <> "<p class=\"text-zinc-500 mb-3 text-sm font-mono\">"
  <> format_date(post.date)
  <> "</p>"
  <> "<p class=\"text-zinc-400 mb-4\">"
  <> escape_html(post.description)
  <> "</p>"
  <> "<div class=\"flex gap-2 flex-wrap\">"
  <> render_tags(post.tags)
  <> "</div>"
  <> "</div>"
  <> "</div>"
  <> "</article>"
}

fn render_blog_page(posts: List(Post)) -> String {
  render_document(
    title: "HeNeos blog",
    description: "A programming blog with Markdown, LaTeX, and code snippets",
    active_path: "/blog",
    highlight: False,
    content: "<div class=\"max-w-4xl mx-auto\">"
      <> "<h1 class=\"text-5xl font-raleway mb-10 text-center\">Blog Posts</h1>"
      <> "<div class=\"space-y-6\">"
      <> render_posts(posts, 1, render_blog_post)
      <> "</div>"
      <> "</div>",
  )
}

fn render_blog_post(post: Post, index: Int) -> String {
  "<article class=\"border border-zinc-800 rounded-lg p-6 card-hover hover:bg-zinc-900/50 backdrop-blur-sm transition-colors\">"
  <> "<div class=\"flex items-start\">"
  <> "<div class=\"text-zinc-500 font-mono mr-4 pt-1 select-none\">"
  <> formatted_counter(index)
  <> "</div>"
  <> "<div class=\"flex-1\">"
  <> "<a href=\""
  <> post_href(post)
  <> "\"><h2 class=\"text-3xl font-raleway mb-2 hover:text-blue-400 transition-colors\">"
  <> escape_html(post.title)
  <> "</h2></a>"
  <> "<p class=\"text-zinc-500 mb-3 text-sm\">"
  <> format_date(post.date)
  <> "</p>"
  <> "<p class=\"text-zinc-400 mb-4\">"
  <> escape_html(post.description)
  <> "</p>"
  <> "<div class=\"flex gap-2 flex-wrap\">"
  <> render_tags(post.tags)
  <> "</div>"
  <> "</div>"
  <> "</div>"
  <> "</article>"
}

fn render_post_page(post: Post) -> String {
  render_document(
    title: post.title <> " | HeNeos blog",
    description: post.description,
    active_path: "",
    highlight: True,
    content: "<div class=\"max-w-5xl mx-auto\">"
      <> "<a class=\"text-zinc-500 hover:text-blue-400 mb-6 inline-block animated-underline\" href=\""
      <> base_path
      <> "/blog\">← Back to all posts</a>"
      <> "<article class=\"container p-1 bg-zinc-900/30\">"
      <> "<header class=\"mb-8 border-b border-zinc-800 pb-6\">"
      <> "<h1 class=\"text-3xl font-bold mb-4 gradient-text\">"
      <> escape_html(post.title)
      <> "</h1>"
      <> "<p class=\"text-zinc-500 mb-4 font-mono\">"
      <> format_date(post.date)
      <> "</p>"
      <> "<div class=\"flex gap-2 flex-wrap\">"
      <> render_tags(post.tags)
      <> "</div>"
      <> "</header>"
      <> "<div class=\"gap-4 mt-8\">"
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
    content: "<div class=\"max-w-4xl mx-auto\">"
      <> "<div class=\"border border-zinc-800 rounded-sm p-8 bg-zinc-900/30\">"
      <> "<h1 class=\"text-4xl font-bold mb-6 border-b border-zinc-800 pb-4\">About Me</h1>"
      <> "<div class=\"line-numbers\">"
      <> "<div class=\"flex items-start my-4\"><span class=\"text-zinc-500 mr-2 select-none\"></span><p class=\"text-zinc-300\">Welcome to my blog! I&#x27;m an engineer with interests in distributed systems, cloud security, algorithms &amp; data structures, and technology in general.</p></div>"
      <> "<div class=\"flex items-start my-4\"><span class=\"text-zinc-500 mr-2 select-none\"></span><p class=\"text-zinc-300\">I used to be a competitive programmer in my college days and still have fun doing that in my barely free time.</p></div>"
      <> "<div class=\"flex items-start my-4\"><span class=\"text-zinc-500 mr-2 select-none\"></span><p class=\"text-zinc-300\">I&#x27;m currently the top 2 solver of my country in Project Euler.</p></div>"
      <> "<div class=\"flex items-start my-4\"><span class=\"text-zinc-500 mr-2 select-none\"></span><div>"
      <> "<h2 class=\"text-2xl font-bold mb-3 text-zinc-100\">My Tech Stack</h2>"
      <> "<p class=\"text-zinc-300 mb-2\">I work with a variety of technologies including:</p>"
      <> "<ul class=\"text-zinc-300 list-none\">"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span>Python</li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span>JavaScript/TypeScript</li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span>AWS</li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span>Kubernetes</li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span>And more!</li>"
      <> "</ul></div></div>"
      <> "<div class=\"flex items-start my-4\"><span class=\"text-zinc-500 mr-2 select-none\"></span><div>"
      <> "<h2 class=\"text-2xl font-bold mb-3 text-zinc-100\">Connect with Me</h2>"
      <> "<p class=\"text-zinc-300 mb-2\">Feel free to reach out to me on social media or check out my work:</p>"
      <> "<ul class=\"text-zinc-300 list-none\">"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span><a href=\"https://github.com/HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:underline\">GitHub</a></li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span><a href=\"https://x.com/_HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:underline\">Twitter</a></li>"
      <> "<li class=\"flex items-center\"><span class=\"text-blue-400 mr-2\">▪</span><a href=\"https://www.linkedin.com/in/heneos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:underline\">LinkedIn</a></li>"
      <> "</ul></div></div>"
      <> "<div class=\"flex items-start my-8\">"
      <> "<a class=\"bg-zinc-800 hover:bg-blue-400 hover:text-zinc-900 text-zinc-100 px-4 py-2 rounded-sm transition-colors\" href=\""
      <> base_path
      <> "/blog\">Check out my blog</a>"
      <> "</div>"
      <> "</div>"
      <> "</div>"
      <> "</div>",
  )
}

fn render_devlog_page() -> String {
  render_document(
    title: "DevLog | HeNeos blog",
    description: "My personal devlog",
    active_path: "/devlog",
    highlight: False,
    content: "<div class=\"max-w-4xl mx-auto\">"
      <> "<div class=\"border border-zinc-800 rounded-sm p-8 bg-zinc-900/30\">"
      <> "<h1 class=\"text-4xl font-mono font-bold mb-6 border-b border-zinc-800 pb-2\">Dev Log</h1>"
      <> "<div class=\"font-mono text-sm space-y-5\">"
      <> render_devlog_entries(devlog_entries())
      <> "</div>"
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
  "<div class=\"relative group flex items-center justify-between\">"
  <> "<div class=\"relative\">"
  <> "<a class=\"font-bold text-blue-300\" href=\""
  <> escape_html(entry.url)
  <> "\">"
  <> escape_html(entry.title)
  <> "</a>"
  <> "<div class=\" absolute left-0 top-full mt-1 w-80 rounded-md border border-zinc-700 bg-zinc-800 p-2 font-mono text-[11px] text-zinc-300 shadow-lg z-50 opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-opacity duration-450 \">"
  <> escape_html(entry.description)
  <> "<div class=\"text-[9px] text-zinc-500 mt-3 border-t border-zinc-700 pt-1\">Added: "
  <> escape_html(entry.added_at)
  <> render_read_date(entry.read_at)
  <> "</div>"
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
    Some(date) -> "<br>Read: " <> escape_html(format_short_date(date))
    None -> ""
  }
}

fn devlog_status_class(read_at: Option(String)) -> String {
  case read_at {
    Some(_) ->
      "text-xs px-2 py-1 rounded border ml-4 bg-green-700 border-green-600 text-green-200"
    None ->
      "text-xs px-2 py-1 rounded border ml-4 bg-zinc-700 border-zinc-600 text-zinc-300"
  }
}

fn devlog_status_text(read_at: Option(String)) -> String {
  case read_at {
    Some(_) -> "Read ✓"
    None -> "Unread"
  }
}

fn render_not_found_page() -> String {
  render_document(
    title: "404: This page could not be found.",
    description: "A programming blog with Markdown, LaTeX, and code snippets",
    active_path: "",
    highlight: False,
    content: "<div style=\"font-family:system-ui,&quot;Segoe UI&quot;,Roboto,Helvetica,Arial,sans-serif,&quot;Apple Color Emoji&quot;,&quot;Segoe UI Emoji&quot;;height:100vh;text-align:center;display:flex;flex-direction:column;align-items:center;justify-content:center\">"
      <> "<div>"
      <> "<style>body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}</style>"
      <> "<h1 class=\"next-error-h1\" style=\"display:inline-block;margin:0 20px 0 0;padding:0 23px 0 0;font-size:24px;font-weight:500;vertical-align:top;line-height:49px\">404</h1>"
      <> "<div style=\"display:inline-block\"><h2 style=\"font-size:14px;font-weight:400;line-height:49px;margin:0\">This page could not be found.</h2></div>"
      <> "</div>"
      <> "</div>",
  )
}

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

fn post_href(post: Post) -> String {
  base_path <> "/blog/" <> escape_html(post.slug)
}

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
  <> "<link rel=\"stylesheet\" href=\""
  <> base_path
  <> "/styles.css\">"
  <> "<link rel=\"stylesheet\" href=\""
  <> base_path
  <> "/katex.min.css\">"
  <> case highlight {
    True ->
      "<link rel=\"stylesheet\" href=\"" <> base_path <> "/github-dark.css\">"
    False -> ""
  }
  <> "</head>"
  <> "<body class=\"bg-zinc-950 text-zinc-100 min-h-screen\">"
  <> render_header(active_path)
  <> "<main class=\"mx-auto px-4 py-6 max-w-5xl\">"
  <> content
  <> "</main>"
  <> render_footer()
  <> "<script src=\""
  <> base_path
  <> "/navigation.js\" defer></script>"
  <> "</body>"
  <> "</html>"
}

fn render_header(active_path: String) -> String {
  "<header class=\"p-6 border-b border-zinc-800\">"
  <> "<div class=\"max-w-6xl mx-auto\">"
  <> "<div class=\"mb-10\">"
  <> "<h1 class=\"text-6xl font-raleway tracking-tighter mb-2 text-center\">HeNeos blog</h1>"
  <> "<p class=\"text-xl font-mono text-center text-zinc-500 mb-1\">Josue H. @ JP Morgan Chase</p>"
  <> "<p class=\"text-xl font-raleway text-center text-zinc-600\">HeNeos</p>"
  <> "</div>"
  <> "<div class=\"flex justify-center space-x-20 mb-4\">"
  <> "<a target=\"_blank\" class=\"text-base font-raleway text-zinc-500 hover:text-accent animated-underline\" href=\"https://github.com/HeNeos\">GitHub</a>"
  <> "<a target=\"_blank\" class=\"text-base font-raleway text-zinc-500 hover:text-accent animated-underline\" href=\"https://www.linkedin.com/in/heneos\">LinkedIn</a>"
  <> "<a class=\"text-base font-raleway text-zinc-500 hover:text-accent animated-underline\" href=\"mailto:he.neos@outlook.com\">Email</a>"
  <> "</div>"
  <> render_navigation(active_path)
  <> "</div>"
  <> "</header>"
}

fn render_navigation(active_path: String) -> String {
  "<div class=\"text-xl font-raleway flex flex-col sm:flex-row justify-center gap-4 border-t border-zinc-800 pt-4\">"
  <> render_navigation_item("Home", "/", "ha", active_path == "/")
  <> render_navigation_item("Blog", "/blog", "hb", active_path == "/blog")
  <> render_navigation_item("About", "/about", "hc", active_path == "/about")
  <> render_navigation_item(
    "Dev Log",
    "/devlog",
    "hd",
    active_path == "/devlog",
  )
  <> "</div>"
}

fn render_navigation_item(
  label: String,
  path: String,
  shortcut: String,
  is_active: Bool,
) -> String {
  "<a class=\"block\" href=\""
  <> navigation_href(path)
  <> "\"><div class=\""
  <> navigation_item_class(is_active)
  <> "\"><span>"
  <> label
  <> "</span><span class=\"ml-6 text-sm font-mono text-zinc-600"
  <> case is_active {
    True -> " font-bold"
    False -> ""
  }
  <> "\">"
  <> shortcut
  <> "</span></div></a>"
}

fn navigation_href(path: String) -> String {
  case path {
    "/" -> base_path
    _ -> base_path <> path
  }
}

fn navigation_item_class(is_active: Bool) -> String {
  case is_active {
    True ->
      "cursor-pointer px-4 py-2 rounded-md flex items-center justify-between transition-all duration-200 bg-zinc-100 text-zinc-900 scale-105 font-medium shadow-[0_0_15px_rgba(255,255,255,0.3)]"
    False ->
      "cursor-pointer px-4 py-2 rounded-md flex items-center justify-between transition-all duration-200 hover:bg-zinc-800 text-zinc-400 hover:text-zinc-100"
  }
}

fn render_footer() -> String {
  "<footer class=\"border-t border-zinc-800 py-6 mt-2\">"
  <> "<div class=\"container mx-auto px-4 relative h-full\">"
  <> "<div class=\"grid grid-cols-1 md:grid-cols-2 gap-8\">"
  <> "<div>"
  <> "<h3 class=\"text-lg font-semibold text-white mb-4\">Connect</h3>"
  <> "<div class=\"flex space-x-4\">"
  <> "<a href=\"https://github.com/HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-slate-400 hover:text-white transition-colors\">GitHub</a>"
  <> "<a href=\"https://x.com/_HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-slate-400 hover:text-white transition-colors\">X</a>"
  <> "<a href=\"https://codeforces.com/profile/HeNeos\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-slate-400 hover:text-white transition-colors\">Codeforces</a>"
  <> "<a href=\"https://codeforces.com/profile/Ptolemy_314\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-slate-400 hover:text-white transition-colors\">Codeforces old</a>"
  <> "</div>"
  <> "</div>"
  <> "<div>"
  <> "<h4 class=\"text-lg font-semibold text-white mb-4\">Project Euler</h4>"
  <> "<a href=\"https://projecteuler.net/profile/HeNeos.png\" target=\"_blank\" rel=\"noopener noreferrer\">"
  <> "<img src=\"https://projecteuler.net/profile/HeNeos.png\" alt=\"Project Euler Profile\" class=\" h-auto max-h-10 rounded-sm object-contain\">"
  <> "</a>"
  <> "</div>"
  <> "</div>"
  <> "</div>"
  <> "</footer>"
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

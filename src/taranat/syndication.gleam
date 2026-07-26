import gleam/list
import gleam/string
import lustre/element
import taranat/date
import taranat/layout
import taranat/post.{type Post}

const static_paths = ["/", "/about", "/blog", "/meet"]

pub fn robots_txt() -> String {
  "User-agent: *\nAllow: /\n\nSitemap: "
  <> layout.site_origin
  <> "/sitemap.xml\n"
}

pub fn sitemap_xml(posts: List(Post)) -> String {
  let statics =
    list.map(static_paths, fn(path) {
      url_entry(layout.site_origin <> path, "")
    })

  let entries =
    list.map(posts, fn(p) {
      url_entry(layout.site_origin <> "/blog/" <> p.slug, p.date)
    })

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  <> string.join(list.append(statics, entries), "\n")
  <> "\n</urlset>\n"
}

fn url_entry(loc: String, lastmod: String) -> String {
  let modified = case lastmod {
    "" -> ""
    date -> "\n    <lastmod>" <> date <> "</lastmod>"
  }
  "  <url>\n    <loc>"
  <> xml_escape(loc)
  <> "</loc>"
  <> modified
  <> "\n  </url>"
}

pub fn feed_xml(posts: List(Post)) -> String {
  let items = string.join(list.map(posts, item), "\n")

  let last_build = case posts {
    [newest, ..] ->
      "    <lastBuildDate>" <> date.rfc822(newest.date) <> "</lastBuildDate>\n"
    [] -> ""
  }

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\n"
  <> "  <channel>\n"
  <> "    <title>Panat Taranat \u{2014} Blog</title>\n"
  <> "    <link>"
  <> layout.site_origin
  <> "/blog</link>\n"
  <> "    <description>Writing by Panat Taranat.</description>\n"
  <> "    <language>en</language>\n"
  <> "    <atom:link href=\""
  <> layout.site_origin
  <> "/feed.xml\" rel=\"self\" type=\"application/rss+xml\" />\n"
  <> last_build
  <> items
  <> "\n  </channel>\n</rss>\n"
}

fn item(p: Post) -> String {
  let link = layout.site_origin <> "/blog/" <> p.slug
  let description = case p.description {
    "" -> absolutize(element.to_string(element.fragment(p.excerpt)))
    text -> text
  }

  "    <item>\n"
  <> "      <title>"
  <> xml_escape(p.title)
  <> "</title>\n"
  <> "      <link>"
  <> xml_escape(link)
  <> "</link>\n"
  <> "      <guid isPermaLink=\"true\">"
  <> xml_escape(link)
  <> "</guid>\n"
  <> "      <pubDate>"
  <> date.rfc822(p.date)
  <> "</pubDate>\n"
  <> "      <description>"
  <> cdata(description)
  <> "</description>\n"
  <> "    </item>"
}

/// Feed readers resolve links against their own origin, not the site's, so
/// site-relative URLs have to be made absolute on the way out. Protocol-
/// relative URLs already carry a host and are left alone.
pub fn absolutize(html: String) -> String {
  use acc, attribute <- list.fold(["href", "src", "srcset"], html)
  let marker = attribute <> "=\""
  case string.split(acc, marker) {
    [before, ..values] ->
      values
      |> list.map(absolutize_attribute)
      |> list.prepend(before)
      |> string.join(marker)
    [] -> acc
  }
}

/// Everything up to the closing quote is the URL list; the rest is markup
/// that happens to follow it.
fn absolutize_attribute(chunk: String) -> String {
  case string.split_once(chunk, "\"") {
    Ok(#(value, rest)) -> absolutize_urls(value) <> "\"" <> rest
    Error(_) -> chunk
  }
}

/// srcset holds several comma-separated candidates; every other attribute is
/// a list of one.
fn absolutize_urls(value: String) -> String {
  value
  |> string.split(",")
  |> list.map(fn(candidate) {
    let url = string.trim_start(candidate)
    case string.starts_with(url, "/") && !string.starts_with(url, "//") {
      True -> string.replace(candidate, url, layout.site_origin <> url)
      False -> candidate
    }
  })
  |> string.join(",")
}

fn xml_escape(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&#39;")
}

fn cdata(text: String) -> String {
  "<![CDATA[" <> string.replace(text, "]]>", "]]]]><![CDATA[>") <> "]]>"
}

import gleam/int
import gleam/list
import gleam/string
import lustre/element
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
      "    <lastBuildDate>" <> rfc822(newest.date) <> "</lastBuildDate>\n"
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
    "" -> element.to_string(element.fragment(p.excerpt))
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
  <> rfc822(p.date)
  <> "</pubDate>\n"
  <> "      <description>"
  <> cdata(description)
  <> "</description>\n"
  <> "    </item>"
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

fn rfc822(iso: String) -> String {
  case parse_date(iso) {
    Ok(#(year, month, day)) ->
      day_of_week(year, month, day)
      <> ", "
      <> pad2(day)
      <> " "
      <> month_abbrev(month)
      <> " "
      <> int.to_string(year)
      <> " 00:00:00 GMT"
    Error(_) -> iso
  }
}

fn parse_date(iso: String) -> Result(#(Int, Int, Int), Nil) {
  case string.split(iso, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(y), Ok(m), Ok(d) -> Ok(#(y, m, d))
        _, _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

/// Zeller's congruence.
fn day_of_week(year: Int, month: Int, day: Int) -> String {
  let #(m, y) = case month < 3 {
    True -> #(month + 12, year - 1)
    False -> #(month, year)
  }
  let k = y % 100
  let j = y / 100
  let h = { day + { 13 * { m + 1 } } / 5 + k + k / 4 + j / 4 + 5 * j } % 7

  case h {
    0 -> "Sat"
    1 -> "Sun"
    2 -> "Mon"
    3 -> "Tue"
    4 -> "Wed"
    5 -> "Thu"
    _ -> "Fri"
  }
}

fn pad2(value: Int) -> String {
  case value < 10 {
    True -> "0" <> int.to_string(value)
    False -> int.to_string(value)
  }
}

fn month_abbrev(month: Int) -> String {
  case month {
    1 -> "Jan"
    2 -> "Feb"
    3 -> "Mar"
    4 -> "Apr"
    5 -> "May"
    6 -> "Jun"
    7 -> "Jul"
    8 -> "Aug"
    9 -> "Sep"
    10 -> "Oct"
    11 -> "Nov"
    _ -> "Dec"
  }
}

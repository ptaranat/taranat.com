import gleam/list
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/layout
import taranat/post.{type Post}

pub fn view(posts: List(Post)) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "Blog \u{2014} Panat Taranat",
      description: "Writing by Panat Taranat.",
      path: "/blog",
      kind: "website",
      image: layout.default_og_image,
    ),
    [
      html.section(
        [
          attribute.class("section section--index"),
          attribute("aria-label", "Blog"),
        ],
        [
          case posts {
            [] -> empty()
            _ -> index(posts)
          },
        ],
      ),
    ],
  )
}

fn empty() -> Element(Nil) {
  html.div([attribute.class("grid")], [
    html.p([attribute.class("col-span-text lede")], [html.text("Coming soon.")]),
  ])
}

fn index(posts: List(Post)) -> Element(Nil) {
  html.div([attribute.class("grid")], [
    html.ul(
      [attribute.class("col-span-full post-index")],
      list.map(posts, entry),
    ),
    html.p([attribute.class("col-span-full post-index__feed")], [
      html.a([attribute.href("/feed.xml")], [html.text("Subscribe via RSS")]),
    ]),
  ])
}

fn entry(p: Post) -> Element(Nil) {
  html.li([attribute.class("post-index__entry")], [
    html.time(
      [attribute.class("post-index__date"), attribute("datetime", p.date)],
      [html.text(post.format_index_date(p.date))],
    ),
    html.div([attribute.class("post-index__body")], [
      html.h2([attribute.class("post-index__title")], [
        html.a(
          [
            attribute.class("post-index__link"),
            attribute.href("/blog/" <> p.slug),
          ],
          [html.text(p.title)],
        ),
      ]),
      html.div([attribute.class("post-index__excerpt")], p.excerpt),
    ]),
  ])
}

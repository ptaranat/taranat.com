import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/layout
import taranat/post.{type Post}

pub fn view(p: Post, assets: String) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: p.title <> " \u{2014} Panat Taranat",
      description: p.description,
      path: "/blog/" <> p.slug,
      kind: "article",
      image: case p.image {
        "" -> layout.default_og_image
        found -> found
      },
    ),
    assets,
    [
      html.article([attribute.class("section section--post")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col-span-text")], [
            header(p),
            html.div([attribute.class("post-body")], p.body),
          ]),
        ]),
      ]),
    ],
  )
}

fn header(p: Post) -> Element(Nil) {
  html.header([attribute.class("post-header")], [
    html.p([attribute.class("post-header__back")], [
      html.a([attribute.href("/blog")], [html.text("\u{2190} All posts")]),
    ]),
    html.h1([attribute.class("display")], [html.text(p.title)]),
    html.time(
      [attribute.class("post-header__date"), attribute("datetime", p.date)],
      [html.text(post.format_date(p.date))],
    ),
  ])
}

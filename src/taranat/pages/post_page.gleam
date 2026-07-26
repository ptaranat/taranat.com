import gleam/option.{type Option, None, Some}
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/date
import taranat/layout
import taranat/post.{type Post}

pub fn view(
  post p: Post,
  newer newer: Option(Post),
  older older: Option(Post),
  assets assets: String,
) -> Element(Nil) {
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
      published: date.iso8601(p.date),
    ),
    assets,
    [
      html.article([attribute.class("section section--post")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col-span-text")], [
            header(p),
            html.div([attribute.class("post-body")], p.body),
            nav(newer, older),
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
      [html.text(date.long(p.date))],
    ),
  ])
}

fn nav(newer: Option(Post), older: Option(Post)) -> Element(Nil) {
  case newer, older {
    None, None -> element.none()
    _, _ ->
      html.nav(
        [attribute.class("post-nav"), attribute("aria-label", "More posts")],
        [link(newer, "newer", "Newer"), link(older, "older", "Older")],
      )
  }
}

/// The empty span keeps a lone neighbour on its own side of the row.
fn link(
  target: Option(Post),
  direction: String,
  label: String,
) -> Element(Nil) {
  case target {
    None -> html.span([], [])
    Some(p) ->
      html.a(
        [
          attribute.class("post-nav__link post-nav__link--" <> direction),
          attribute.href("/blog/" <> p.slug),
        ],
        [
          html.span([attribute.class("post-nav__label")], [html.text(label)]),
          html.span([attribute.class("post-nav__title")], [html.text(p.title)]),
        ],
      )
  }
}

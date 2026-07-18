import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import taranat/layout

pub fn view() -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "404 \u{2014} Panat Taranat",
      description: "",
      path: "",
      kind: "website",
      image: layout.default_og_image,
    ),
    [
      html.section([attribute.class("section section--hero")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col-span-text")], [
            html.h1([attribute.class("display")], [html.text("404")]),
            html.p([attribute.class("lede")], [
              html.text("Nothing here. "),
              html.a([attribute.href("/")], [html.text("Back to the index.")]),
            ]),
          ]),
        ]),
      ]),
    ],
  )
}

import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/layout

pub fn view(assets: String) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "Schedule a meeting \u{2014} Panat Taranat",
      description: "Find a time to chat with Panat Taranat.",
      path: "/meet",
      kind: "website",
      image: layout.default_og_image,
    ),
    assets,
    [
      html.section([attribute.class("section section--meet")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col-span-text")], [
            html.h1([attribute.class("display")], [
              html.text("Grab some time with me"),
            ]),
            html.p([attribute.class("lede")], [
              html.text(
                "Here's my calendar. Happy to talk software, the bookstore, or anything you're working on.",
              ),
            ]),
          ]),
          html.div([attribute.class("col-span-full meet-embed")], [
            html.iframe([
              attribute.src("https://app.cal.com/panat"),
              attribute("title", "Schedule a meeting with Panat"),
              attribute("loading", "lazy"),
              attribute("allowfullscreen", ""),
            ]),
          ]),
        ]),
      ]),
    ],
  )
}

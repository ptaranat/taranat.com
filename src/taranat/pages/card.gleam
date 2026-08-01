import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import taranat/email
import taranat/layout
import taranat/ui
import taranat/vcard

pub fn view(assets: String) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: vcard.full_name() <> ", " <> vcard.title <> " at " <> vcard.org,
      description: "Contact card for " <> vcard.full_name() <> ".",
      path: "/card",
      kind: "profile",
      image: layout.default_og_image,
      published: "",
    ),
    assets,
    [
      html.section([attribute.class("section section--card")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col-span-text vcard")], [
            html.figure([attribute.class("vcard__photo")], [
              ui.responsive_image(ui.Image(
                base: "/assets/panat-watercolor",
                widths: [400, 736],
                format: "jpg",
                sizes: "12rem",
                alt: "Watercolor portrait of " <> vcard.full_name(),
                width: 736,
                height: 736,
                loading: ui.Eager,
              )),
            ]),
            html.h1([attribute.class("display")], [
              html.text(vcard.full_name()),
            ]),
            html.p([attribute.class("vcard__role")], [
              html.text(vcard.title <> ", " <> vcard.org),
            ]),
            // A download attribute sends iOS to Files instead of the native
            // "Add to Contacts" sheet.
            html.a(
              [
                attribute.class("vcard__save"),
                attribute.href("/" <> vcard.filename),
              ],
              [html.text("Save to contacts")],
            ),
            html.ul([attribute.class("contact-list vcard__links")], [
              html.li([], [email.link()]),
              html.li([], [
                html.a([attribute.href("/meet")], [html.text("Book a call")]),
              ]),
              html.li([], [
                html.a(
                  [
                    attribute.href("https://dungeonbooks.com"),
                    attribute.rel("noreferrer"),
                  ],
                  [html.text("dungeonbooks.com")],
                ),
              ]),
              html.li([], [
                html.a([attribute.href("/about")], [html.text("About me")]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ],
  )
}

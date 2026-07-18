import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html

const user = "panat"

const domain = "taranat.com"

/// Assembled by /js/email.js so the address never appears in the markup.
pub fn link() -> Element(msg) {
  html.a(
    [
      attribute.class("obf-email"),
      attribute.href("#"),
      attribute("data-u", user),
      attribute("data-d", domain),
    ],
    [html.text(human_readable())],
  )
}

fn human_readable() -> String {
  user <> " at " <> string.replace(domain, ".", " dot ")
}

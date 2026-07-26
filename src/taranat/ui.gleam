import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn definition(
  word word: String,
  part_of_speech part_of_speech: String,
  meaning meaning: String,
) -> Element(msg) {
  html.p([attribute.class("definition")], [
    html.dfn([], [html.text(word)]),
    html.text(" "),
    html.span([attribute.class("definition__pos")], [html.text(part_of_speech)]),
    html.text(" " <> meaning),
  ])
}

pub type Loading {
  Eager
  Lazy
}

/// Variants are named `<base>-<width>.<format>`, each with a `.webp` sibling.
pub type Image {
  Image(
    base: String,
    widths: List(Int),
    format: String,
    sizes: String,
    alt: String,
    width: Int,
    height: Int,
    loading: Loading,
  )
}

pub fn responsive_image(image: Image) -> Element(msg) {
  let assert [_, ..] = image.widths as "a responsive image needs a width"

  html.picture([], [
    html.source([
      attribute.type_("image/webp"),
      attribute.srcset(srcset(image.base, image.widths, "webp")),
      attribute.attribute("sizes", image.sizes),
    ]),
    html.img([
      attribute.src(variant(image.base, largest(image.widths), image.format)),
      attribute.srcset(srcset(image.base, image.widths, image.format)),
      attribute.attribute("sizes", image.sizes),
      attribute.alt(image.alt),
      attribute.attribute("width", int.to_string(image.width)),
      attribute.attribute("height", int.to_string(image.height)),
      attribute.attribute("loading", loading_value(image.loading)),
    ]),
  ])
}

/// Post content, where the only variant is a `.webp` beside the original and
/// remote images cannot be measured at all.
pub fn content_image(
  src src: String,
  webp webp: Option(String),
  alt alt: String,
  size size: Option(#(Int, Int)),
) -> Element(msg) {
  let sources = case webp {
    Some(path) -> [
      html.source([attribute.type_("image/webp"), attribute.srcset(path)]),
    ]
    None -> []
  }

  let dimensions = case size {
    Some(#(width, height)) -> [
      attribute.attribute("width", int.to_string(width)),
      attribute.attribute("height", int.to_string(height)),
    ]
    None -> []
  }

  let image =
    html.img([
      attribute.src(src),
      attribute.alt(alt),
      attribute.attribute("loading", "lazy"),
      attribute.attribute("decoding", "async"),
      ..dimensions
    ])

  html.picture([], list.append(sources, [image]))
}

fn loading_value(loading: Loading) -> String {
  case loading {
    Eager -> "eager"
    Lazy -> "lazy"
  }
}

fn variant(base: String, width: Int, format: String) -> String {
  base <> "-" <> int.to_string(width) <> "." <> format
}

fn srcset(base: String, widths: List(Int), format: String) -> String {
  widths
  |> list.sort(int.compare)
  |> list.map(fn(width) {
    variant(base, width, format) <> " " <> int.to_string(width) <> "w"
  })
  |> string.join(", ")
}

fn largest(widths: List(Int)) -> Int {
  list.fold(widths, 0, int.max)
}

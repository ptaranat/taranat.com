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

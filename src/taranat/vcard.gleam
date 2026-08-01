import gleam/bit_array
import gleam/list
import gleam/string
import simplifile

const photo_path = "public/assets/panat-profile-400.jpg"

const crlf = "\r\n"

const max_octets = 75

pub const given_name = "Panat"

pub const family_name = "Taranat"

pub const org = "Dungeon Books"

pub const title = "Wizard in Chief"

pub const email = "panat@taranat.com"

pub const url = "https://taranat.com"

const note = "Software engineer. Sci-fi and fantasy bookstore in Jersey City."

pub const filename = "panat-taranat.vcf"

pub fn full_name() -> String {
  given_name <> " " <> family_name
}

pub fn text() -> String {
  [
    [
      "BEGIN:VCARD",
      "VERSION:3.0",
      "N:" <> escape(family_name) <> ";" <> escape(given_name) <> ";;;",
      "FN:" <> escape(full_name()),
      "ORG:" <> escape(org),
      "TITLE:" <> escape(title),
      "EMAIL;TYPE=INTERNET;TYPE=PREF:" <> email,
      "URL:" <> url,
      "NOTE:" <> escape(note),
    ],
    photo_line(),
    ["END:VCARD"],
  ]
  |> list.flatten
  |> list.flat_map(fold)
  |> string.join(crlf)
  |> string.append(crlf)
}

fn photo_line() -> List(String) {
  case simplifile.read_bits(photo_path) {
    Ok(bytes) -> [
      "PHOTO;ENCODING=b;TYPE=JPEG:" <> bit_array.base64_encode(bytes, True),
    ]
    Error(_) -> []
  }
}

pub fn escape(value: String) -> String {
  value
  |> string.replace("\\", "\\\\")
  |> string.replace("\n", "\\n")
  |> string.replace(";", "\\;")
  |> string.replace(",", "\\,")
}

/// The limit is octets, not characters, and a continuation line spends one on
/// the leading space that marks it. Graphemes move whole rather than splitting.
pub fn fold(line: String) -> List(String) {
  wrap(string.to_graphemes(line), max_octets, [])
}

fn wrap(
  graphemes: List(String),
  budget: Int,
  done: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(done)
    _ -> {
      let #(taken, rest) = take(graphemes, budget, "")
      let line = case done {
        [] -> taken
        _ -> " " <> taken
      }
      wrap(rest, max_octets - 1, [line, ..done])
    }
  }
}

fn take(
  graphemes: List(String),
  budget: Int,
  taken: String,
) -> #(String, List(String)) {
  case graphemes {
    [] -> #(taken, [])
    [grapheme, ..rest] -> {
      let size = bit_array.byte_size(bit_array.from_string(grapheme))
      // Always take one, or a grapheme wider than the budget never advances.
      case size <= budget || taken == "" {
        True -> take(rest, budget - size, taken <> grapheme)
        False -> #(taken, graphemes)
      }
    }
  }
}

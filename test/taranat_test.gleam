import gleam/bit_array
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import mork/document.{type Block, Heading, Text}
import simplifile
import taranat/date
import taranat/image
import taranat/post
import taranat/syndication
import taranat/vcard

pub fn main() {
  gleeunit.main()
}

pub fn jpeg_dimensions_test() {
  image.dimensions("/assets/her-theodore-desk.jpg")
  |> should.equal(Ok(image.Dimensions(800, 450)))

  image.dimensions("/assets/dungeonbooks-shelves-1500.jpg")
  |> should.equal(Ok(image.Dimensions(1500, 1000)))
}

pub fn png_dimensions_test() {
  image.dimensions("/assets/neuralwatt-usage.png")
  |> should.equal(Ok(image.Dimensions(881, 662)))

  image.dimensions("/assets/og-default.png")
  |> should.equal(Ok(image.Dimensions(1200, 630)))
}

pub fn unmeasurable_dimensions_test() {
  // Remote images are never opened.
  image.dimensions("https://example.com/bicycle.jpg")
  |> should.equal(Error(Nil))

  image.dimensions("/assets/does-not-exist.jpg")
  |> should.equal(Error(Nil))

  // A format the decoder does not know.
  image.dimensions("/assets/noise-dark.svg")
  |> should.equal(Error(Nil))

  // public/favicon.png is a readable, decodable PNG, but reaching it from
  // outside the assets directory is still refused.
  image.dimensions("/assets/../favicon.png")
  |> should.equal(Error(Nil))
}

pub fn webp_sibling_test() {
  image.webp_sibling("/assets/her-theodore-desk.jpg")
  |> should.equal(Ok("/assets/her-theodore-desk.webp"))

  image.webp_sibling("/assets/og-default.png")
  |> should.equal(Error(Nil))

  image.webp_sibling("/assets/no-extension")
  |> should.equal(Error(Nil))

  // Remote images are never probed on disk.
  image.webp_sibling("https://example.com/bicycle.jpg")
  |> should.equal(Error(Nil))
}

pub fn long_date_test() {
  date.long("2026-05-02")
  |> should.equal("May 2, 2026")

  date.long("2026-12-25")
  |> should.equal("December 25, 2026")
}

pub fn index_date_test() {
  date.index("2026-05-02")
  |> should.equal("MAY 02, 2026")

  date.index("2025-08-12")
  |> should.equal("AUG 12, 2025")
}

pub fn rfc822_date_test() {
  date.rfc822("2026-05-02")
  |> should.equal("Sat, 02 May 2026 00:00:00 GMT")

  // January and February count as months 13 and 14 of the prior year in
  // Zeller's congruence, so they are the interesting cases.
  date.rfc822("2026-01-01")
  |> should.equal("Thu, 01 Jan 2026 00:00:00 GMT")

  date.rfc822("2024-02-29")
  |> should.equal("Thu, 29 Feb 2024 00:00:00 GMT")
}

pub fn iso8601_test() {
  date.iso8601("2026-05-02")
  |> should.equal("2026-05-02T00:00:00Z")

  // A meta tag is better omitted than filled with something unparseable.
  date.iso8601("not a date")
  |> should.equal("")
}

/// Anything unparseable is passed through untouched rather than guessed at.
pub fn malformed_date_test() {
  date.long("")
  |> should.equal("")

  date.index("not a date")
  |> should.equal("not a date")

  date.rfc822("2026-13-02")
  |> should.equal("2026-13-02")

  // Days are checked against the month, not just against 31.
  date.long("2026-04-31")
  |> should.equal("2026-04-31")

  date.long("2025-02-29")
  |> should.equal("2025-02-29")

  date.long("2024-02-29")
  |> should.equal("February 29, 2024")

  // 1900 is not a leap year; 2000 is.
  date.long("1900-02-29")
  |> should.equal("1900-02-29")

  date.long("2000-02-29")
  |> should.equal("February 29, 2000")
}

pub fn absolutize_test() {
  syndication.absolutize(
    "<a href=\"/blog/bicycle\"><img src=\"/assets/a.jpg\"></a>",
  )
  |> should.equal(
    "<a href=\"https://taranat.com/blog/bicycle\"><img src=\"https://taranat.com/assets/a.jpg\"></a>",
  )

  // Absolute and anchor URLs are left alone.
  syndication.absolutize("<a href=\"https://example.com/x\">x</a>")
  |> should.equal("<a href=\"https://example.com/x\">x</a>")

  syndication.absolutize("<a href=\"#notes\">notes</a>")
  |> should.equal("<a href=\"#notes\">notes</a>")

  // Protocol-relative URLs already carry a host.
  syndication.absolutize("<img src=\"//cdn.example.com/x.jpg\">")
  |> should.equal("<img src=\"//cdn.example.com/x.jpg\">")

  // Every candidate in a srcset is rewritten, not just the first.
  syndication.absolutize("<source srcset=\"/a.webp 800w, /b.webp 1400w\">")
  |> should.equal(
    "<source srcset=\"https://taranat.com/a.webp 800w, https://taranat.com/b.webp 1400w\">",
  )

  // Text after the attribute is left intact.
  syndication.absolutize("<a href=\"/x\">a, b</a>")
  |> should.equal("<a href=\"https://taranat.com/x\">a, b</a>")
}

pub fn slug_test() {
  post.slug("The NDA Red Flag")
  |> should.equal("the-nda-red-flag")

  post.slug("Update: there\u{2019}s a better way")
  |> should.equal("update-theres-a-better-way")

  post.slug("  .NET  BS  ")
  |> should.equal("net-bs")

  post.slug("Update: there's a better way")
  |> should.equal("update-theres-a-better-way")

  post.slug("!!!")
  |> should.equal("")
}

fn heading(text: String, id: String) -> Block {
  Heading(2, id, "", [Text(text)])
}

fn heading_ids(blocks: List(Block)) -> List(String) {
  use block <- list.filter_map(post.identify_headings(blocks))
  case block {
    Heading(_, id, _, _) -> Ok(id)
    _ -> Error(Nil)
  }
}

pub fn heading_id_test() {
  // Repeated titles are suffixed rather than colliding.
  heading_ids([heading("The setup", ""), heading("The setup", "")])
  |> should.equal(["the-setup", "the-setup-1"])

  // An id written in the source is claimed, so a later auto slug avoids it.
  heading_ids([heading("anything", "the-setup"), heading("The setup", "")])
  |> should.equal(["the-setup", "the-setup-1"])

  // Headings that slug to nothing get a name instead of a bare suffix.
  heading_ids([heading("!!!", ""), heading("???", "")])
  |> should.equal(["section", "section-1"])
}

pub fn unquote_test() {
  post.unquote("\"Bicycle\"")
  |> should.equal("Bicycle")

  post.unquote("'Bicycle'")
  |> should.equal("Bicycle")

  post.unquote("Bicycle")
  |> should.equal("Bicycle")

  // A lone quote is not a quoted empty string.
  post.unquote("'")
  |> should.equal("'")

  post.unquote("\"")
  |> should.equal("\"")

  post.unquote("")
  |> should.equal("")
}

pub fn frontmatter_test() {
  let meta =
    post.parse_frontmatter(
      "title: \"Bicycle\"\ndate: 2026-05-02\ndraft: false\ndescription: \"Colons: inside a value\"",
    )

  post.field(meta, "title", "")
  |> should.equal("Bicycle")

  post.field(meta, "date", "")
  |> should.equal("2026-05-02")

  // Splitting on the first colon keeps the rest of the value intact.
  post.field(meta, "description", "")
  |> should.equal("Colons: inside a value")

  post.field(meta, "missing", "fallback")
  |> should.equal("fallback")
}

fn octets(value: String) -> Int {
  bit_array.byte_size(bit_array.from_string(value))
}

pub fn vcard_escape_test() {
  vcard.escape("Sci-fi, fantasy; and RPGs")
  |> should.equal("Sci-fi\\, fantasy\\; and RPGs")

  // The backslash is doubled first, so an escape introduced afterwards is not
  // doubled in turn.
  vcard.escape("a\\b,c")
  |> should.equal("a\\\\b\\,c")

  vcard.escape("line one\nline two")
  |> should.equal("line one\\nline two")

  vcard.escape("nothing to do")
  |> should.equal("nothing to do")
}

pub fn vcard_fold_test() {
  vcard.fold("short")
  |> should.equal(["short"])

  let folded = vcard.fold(string.repeat("a", 200))
  list.map(folded, octets)
  |> should.equal([75, 75, 52])

  // Continuation lines carry a leading space the parser strips back out.
  folded
  |> list.drop(1)
  |> list.all(string.starts_with(_, " "))
  |> should.be_true

  string.concat(list.map(folded, string.replace(_, " ", "")))
  |> should.equal(string.repeat("a", 200))
}

/// The limit is octets, so counting characters overruns it on anything that is
/// not ASCII.
pub fn vcard_fold_multibyte_test() {
  let folded = vcard.fold(string.repeat("\u{00E9}", 120))

  list.map(folded, octets)
  |> list.all(fn(size) { size <= 75 })
  |> should.be_true

  string.concat(list.map(folded, string.replace(_, " ", "")))
  |> should.equal(string.repeat("\u{00E9}", 120))
}

pub fn vcard_text_test() {
  let text = vcard.text()
  let lines = string.split(text, "\r\n")

  // Bare newlines would break parsers that split on CRLF.
  string.replace(text, "\r\n", "")
  |> string.contains("\n")
  |> should.be_false

  list.map(lines, octets)
  |> list.all(fn(size) { size <= 75 })
  |> should.be_true

  list.first(lines)
  |> should.equal(Ok("BEGIN:VCARD"))

  string.ends_with(text, "END:VCARD\r\n")
  |> should.be_true

  // N: is family-first and must stay in step with FN:.
  list.contains(lines, "N:Taranat;Panat;;;")
  |> should.be_true

  list.contains(lines, "FN:" <> vcard.full_name())
  |> should.be_true
}

pub fn vcard_photo_test() {
  let assert Ok(source) =
    simplifile.read_bits("public/assets/panat-profile-400.jpg")

  let encoded =
    vcard.text()
    |> string.split("\r\n")
    |> unfold
    |> list.filter_map(fn(line) {
      case string.split_once(line, "PHOTO;ENCODING=b;TYPE=JPEG:") {
        Ok(#("", data)) -> Ok(data)
        _ -> Error(Nil)
      }
    })
    |> list.first

  encoded
  |> should.equal(Ok(bit_array.base64_encode(source, True)))
}

/// Rejoins continuation lines onto the line they were split from.
fn unfold(lines: List(String)) -> List(String) {
  use acc, line <- list.fold(lines, [])
  case string.starts_with(line, " "), acc {
    True, [previous, ..rest] -> [previous <> string.drop_start(line, 1), ..rest]
    _, _ -> [line, ..acc]
  }
}

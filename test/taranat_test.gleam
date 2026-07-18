import gleeunit
import gleeunit/should
import taranat/post

pub fn main() {
  gleeunit.main()
}

pub fn format_date_test() {
  post.format_date("2026-05-02")
  |> should.equal("May 2, 2026")

  post.format_date("2026-12-25")
  |> should.equal("December 25, 2026")

  post.format_date("")
  |> should.equal("")
}

pub fn format_index_date_test() {
  post.format_index_date("2026-05-02")
  |> should.equal("MAY 02, 2026")

  post.format_index_date("2025-08-12")
  |> should.equal("AUG 12, 2025")
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

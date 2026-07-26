import gleeunit
import gleeunit/should
import taranat/image
import taranat/post

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

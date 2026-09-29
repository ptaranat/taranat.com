import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import simplifile
import tom.{type Toml}

const dir = "content/shelves"

/// The book club shelves come from the ssh-bookshop API, not a file here, so
/// the picks and their buy links live in one place (its bookclub.go). The
/// Dockerfile fetches it at build; `just shelf` does the same locally. The file
/// is not committed.
const book_club_file = "content/shelves/book-club.json"

/// Which club each shelf shows, in render order, by the API's collection.
const clubs = [
  #("book club", "Sci-Fi & Fantasy book club"),
  #("horror book club", "Horror book club"),
]

/// Covers keyed by the edition we sell, where that edition's art is wrong for
/// a spine row. The Poet Empress deluxe is a 3/4 render; show the ebook's flat
/// front art (9781250406828) instead.
const cover_overrides = [#("9781250406811", "9781250406828")]

const cover_base = "https://assets.dungeonbooks.com/cdn-cgi/image/width=208,format=auto/covers/raw/"

pub type Book {
  Book(
    title: String,
    author: String,
    url: String,
    note: String,
    isbn: String,
    month: String,
  )
}

pub type Shelf {
  Shelf(title: String, books: List(Book))
}

/// The TOML shelves render in filename order, then the book clubs. A missing or
/// malformed file yields an empty shelf rather than a failed build, so a bad
/// sync or an unreachable API cannot take the site down.
pub fn load() -> List(Shelf) {
  let toml = case simplifile.read_directory(dir) {
    Error(_) -> []
    Ok(files) ->
      files
      |> list.filter(string.ends_with(_, ".toml"))
      |> list.sort(string.compare)
      |> list.filter_map(shelf)
  }
  let club = case simplifile.read(book_club_file) {
    Ok(source) -> book_clubs(source)
    Error(_) -> []
  }
  list.append(toml, club)
  |> list.filter(fn(s) { s.books != [] })
}

type Pick {
  Pick(
    collection: String,
    title: String,
    author: String,
    isbn: String,
    month: String,
    product_url: String,
    buy_url: String,
  )
}

/// book_clubs splits a /v1/books response into one shelf per club, keeping the
/// API's order, which is newest first.
pub fn book_clubs(source: String) -> List(Shelf) {
  let pick = {
    use collection <- decode.field("collection", decode.string)
    use title <- decode.field("title", decode.string)
    use author <- decode.field("author", decode.string)
    use isbn <- decode.field("isbn", decode.string)
    use month <- decode.optional_field("month", "", decode.string)
    use product_url <- decode.optional_field("product_url", "", decode.string)
    use buy_url <- decode.optional_field("buy_url", "", decode.string)
    decode.success(Pick(
      collection:,
      title:,
      author:,
      isbn:,
      month:,
      product_url:,
      buy_url:,
    ))
  }
  let decoder = decode.at(["books"], decode.list(pick))

  case json.parse(source, decoder) {
    Error(_) -> []
    Ok(picks) ->
      list.map(clubs, fn(club) {
        let #(collection, title) = club
        Shelf(
          title:,
          books: picks
            |> list.filter(fn(p) { p.collection == collection })
            |> list.map(to_book),
        )
      })
  }
}

/// A book we carry links to its page at dungeonbooks.com, one we don't to
/// Bookshop; the API has already decided which applies.
fn to_book(p: Pick) -> Book {
  let url = case p.product_url, p.buy_url {
    "", "" -> "https://bookshop.org/a/108216/" <> p.isbn
    "", buy -> buy
    product, _ -> product
  }
  Book(
    title: p.title,
    author: p.author,
    url:,
    note: "",
    isbn: list.key_find(cover_overrides, p.isbn) |> result.unwrap(p.isbn),
    month: month_label(p.month),
  )
}

/// "2026-09" as "Sep 2026", the way the shelf has always captioned a pick.
pub fn month_label(month: String) -> String {
  let names = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
    "Dec",
  ]
  case string.split(month, "-") {
    [year, m] ->
      case int.parse(m) {
        Ok(n) if n >= 1 && n <= 12 ->
          case list.drop(names, n - 1) {
            [name, ..] -> name <> " " <> year
            [] -> month
          }
        _ -> month
      }
    _ -> month
  }
}

fn shelf(file: String) -> Result(Shelf, Nil) {
  use source <- result.try(
    simplifile.read(dir <> "/" <> file) |> result.replace_error(Nil),
  )
  use parsed <- result.try(tom.parse(source) |> result.replace_error(Nil))

  let books = case tom.get(parsed, ["book"]) {
    Ok(tom.ArrayOfTables(tables)) -> list.filter_map(tables, book)
    _ -> []
  }

  Ok(Shelf(title: result.unwrap(string_field(parsed, "title"), ""), books:))
}

fn book(table: Dict(String, Toml)) -> Result(Book, Nil) {
  use title <- result.try(string_field(table, "title"))
  Ok(Book(
    title:,
    author: result.unwrap(string_field(table, "author"), ""),
    url: result.unwrap(string_field(table, "url"), ""),
    note: result.unwrap(string_field(table, "note"), ""),
    isbn: result.unwrap(string_field(table, "isbn"), ""),
    month: result.unwrap(string_field(table, "month"), ""),
  ))
}

fn string_field(table: Dict(String, Toml), key: String) -> Result(String, Nil) {
  tom.get_string(table, [key]) |> result.replace_error(Nil)
}

pub fn view(shelves: List(Shelf)) -> Element(Nil) {
  case shelves {
    [] -> element.none()
    _ -> html.div([attribute.class("shelves")], list.map(shelves, shelf_view))
  }
}

fn shelf_view(s: Shelf) -> Element(Nil) {
  html.div([attribute.class("shelf")], [
    html.h2([attribute.class("shelf__title")], [html.text(s.title)]),
    html.div([attribute.class("shelf__viewport")], [
      html.ul([attribute.class("shelf__row")], list.map(s.books, spine)),
      // Hidden until shelves.js finds the row overflows, so without JS, or on
      // a short shelf, there is nothing to click that does nothing.
      // Named for their shelf, so a screen reader listing buttons can tell
      // the three pairs apart.
      arrow("prev", "Scroll " <> s.title <> " back", "\u{2039}"),
      arrow("next", "Scroll " <> s.title <> " forward", "\u{203A}"),
    ]),
  ])
}

fn arrow(dir: String, label: String, glyph: String) -> Element(Nil) {
  html.button(
    [
      attribute.class("shelf__arrow shelf__arrow--" <> dir),
      attribute.type_("button"),
      attribute("aria-label", label),
      attribute("data-dir", dir),
      attribute("hidden", ""),
    ],
    [html.text(glyph)],
  )
}

fn spine(b: Book) -> Element(Nil) {
  let label = case b.author {
    "" -> b.title
    author -> b.title <> " by " <> author
  }

  let inner = case b.isbn {
    "" -> [html.span([attribute.class("shelf__blank")], [html.text(b.title)])]
    isbn -> [
      html.img([
        attribute.class("shelf__cover"),
        attribute.src(cover_base <> isbn <> ".jpg"),
        attribute.alt(label),
        attribute("loading", "lazy"),
        attribute("decoding", "async"),
        attribute("width", "104"),
        attribute("height", "156"),
      ]),
    ]
  }

  let caption =
    list.flatten([
      case b.month {
        "" -> []
        m -> [html.span([attribute.class("shelf__month")], [html.text(m)])]
      },
      [html.span([attribute.class("shelf__name")], [html.text(b.title)])],
    ])

  let body =
    list.append(inner, [html.span([attribute.class("shelf__caption")], caption)])

  html.li([attribute.class("shelf__item")], [
    case b.url {
      "" -> html.span([attribute("title", label)], body)
      url ->
        html.a(
          [
            attribute.href(url),
            attribute.rel("noreferrer"),
            attribute("title", label),
          ],
          body,
        )
    },
  ])
}

import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import simplifile
import tom.{type Toml}

const dir = "content/shelves"

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

/// Shelves render in filename order. A missing or malformed file yields an
/// empty shelf rather than a failed build, so a bad sync cannot take the site
/// down.
pub fn load() -> List(Shelf) {
  case simplifile.read_directory(dir) {
    Error(_) -> []
    Ok(files) ->
      files
      |> list.filter(string.ends_with(_, ".toml"))
      |> list.sort(string.compare)
      |> list.filter_map(shelf)
      |> list.filter(fn(s) { s.books != [] })
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
    html.ul([attribute.class("shelf__row")], list.map(s.books, spine)),
  ])
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

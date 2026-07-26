import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import mork
import mork/document.{
  type Block, type Destination, type Document, type Inline, Absolute, Anchor,
  Code, CodeSpan, Document, Emphasis, FullImage, FullLink, Highlight, Paragraph,
  Relative, SoftBreak, Strikethrough, Strong, Text,
}
import mork/to_lustre
import simplifile
import smalto
import smalto/grammar.{type Grammar}
import smalto/languages/bash
import smalto/languages/json
import smalto/languages/typescript
import smalto/languages/yaml
import taranat/image
import taranat/ui

const posts_dir = "content/posts"

const more_marker = "<!--more-->"

pub type Post {
  Post(
    slug: String,
    title: String,
    date: String,
    description: String,
    draft: Bool,
    image: String,
    body: List(Element(Nil)),
    excerpt: List(Element(Nil)),
  )
}

pub fn load_all() -> List(Post) {
  let assert Ok(files) = simplifile.read_directory(posts_dir)

  files
  |> list.filter(fn(f) { string.ends_with(f, ".md") })
  |> list.map(load)
  |> list.sort(fn(a, b) { string.compare(b.date, a.date) })
}

pub fn published(posts: List(Post)) -> List(Post) {
  list.filter(posts, fn(p) { !p.draft })
}

pub fn by_slug(posts: List(Post)) -> Dict(String, Post) {
  posts
  |> list.map(fn(p) { #(p.slug, p) })
  |> dict.from_list
}

fn load(file: String) -> Post {
  let slug = string.replace(file, ".md", "")
  let assert Ok(source) = simplifile.read(posts_dir <> "/" <> file)
  let #(frontmatter, content) = mork.split_frontmatter_from_input(source)
  let meta = parse_frontmatter(frontmatter)

  Post(
    slug: slug,
    title: field(meta, "title", slug),
    date: string.slice(field(meta, "date", ""), 0, 10),
    description: field(meta, "description", ""),
    draft: field(meta, "draft", "") == "true",
    image: case field(meta, "image", "") {
      "" -> first_image(content)
      found -> found
    },
    body: render(string.replace(content, more_marker, "")),
    excerpt: render(build_excerpt(content)),
  )
}

/// Frontmatter is a flat `key: value` block; values may be quoted.
pub fn parse_frontmatter(frontmatter: String) -> Dict(String, String) {
  frontmatter
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    case string.split_once(line, ":") {
      Ok(#(key, value)) -> Ok(#(string.trim(key), unquote(string.trim(value))))
      Error(_) -> Error(Nil)
    }
  })
  |> dict.from_list
}

pub fn unquote(value: String) -> String {
  let quoted = fn(mark) {
    string.starts_with(value, mark) && string.ends_with(value, mark)
  }
  case string.length(value) >= 2 && { quoted("\"") || quoted("'") } {
    True -> string.slice(value, 1, string.length(value) - 2)
    False -> value
  }
}

pub fn field(
  meta: Dict(String, String),
  key: String,
  fallback: String,
) -> String {
  case dict.get(meta, key) {
    Ok(value) -> value
    Error(_) -> fallback
  }
}

fn build_excerpt(content: String) -> String {
  case string.split_once(content, more_marker) {
    Ok(#(before, _)) -> string.trim(strip_leading_media(before))
    Error(_) ->
      content
      |> strip_leading_media
      |> string.split("\n\n")
      |> list.find(fn(block) { string.trim(block) != "" })
      |> fn(found) {
        case found {
          Ok(block) -> string.trim(block)
          Error(_) -> ""
        }
      }
  }
}

fn strip_leading_media(source: String) -> String {
  source
  |> string.trim
  |> string.split("\n\n")
  |> drop_leading_images
  |> string.join("\n\n")
}

fn drop_leading_images(blocks: List(String)) -> List(String) {
  case blocks {
    [first, ..rest] ->
      case string.starts_with(string.trim(first), "![") {
        True -> drop_leading_images(rest)
        False -> blocks
      }
    [] -> []
  }
}

fn first_image(content: String) -> String {
  case string.split_once(content, "![") {
    Error(_) -> ""
    Ok(#(_, after_bang)) ->
      case string.split_once(after_bang, "](") {
        Error(_) -> ""
        Ok(#(_, after_bracket)) ->
          case string.split_once(after_bracket, ")") {
            Error(_) -> ""
            Ok(#(url, _)) -> url
          }
      }
  }
}

fn options() -> document.Options {
  mork.configure()
  |> mork.tables(True)
  |> mork.tasklists(True)
  |> mork.autolinks(True)
  |> mork.footnotes(False)
}

/// mork_to_lustre renders a whole document with no per-node hook, so code
/// blocks and figures are pulled out and rendered here while every other run
/// of blocks is delegated back to it.
fn render(markdown: String) -> List(Element(Nil)) {
  let doc = mork.parse_with_options(options(), markdown)

  doc.blocks
  |> chunk
  |> list.flat_map(fn(chunk) {
    case chunk {
      CodeChunk(lang, text) -> [code_block(option.unwrap(lang, "text"), text)]
      FigureChunk(src, alt, caption) -> [figure(doc, src, alt, caption)]
      BlockChunk(blocks) -> to_lustre.to_lustre(Document(..doc, blocks: blocks))
    }
  })
}

type Chunk {
  CodeChunk(lang: Option(String), text: String)
  FigureChunk(src: String, alt: String, caption: List(Inline))
  BlockChunk(blocks: List(Block))
}

fn chunk(blocks: List(Block)) -> List(Chunk) {
  list.fold(blocks, [], fn(acc, block) {
    case as_chunk(block), acc {
      Ok(chunk), _ -> [chunk, ..acc]
      Error(_), [BlockChunk(pending), ..rest] -> [
        BlockChunk([block, ..pending]),
        ..rest
      ]
      Error(_), _ -> [BlockChunk([block]), ..acc]
    }
  })
  |> list.reverse
  |> list.map(fn(chunk) {
    case chunk {
      BlockChunk(blocks) -> BlockChunk(list.reverse(blocks))
      other -> other
    }
  })
}

/// Blocks this module renders itself rather than handing to mork_to_lustre.
fn as_chunk(block: Block) -> Result(Chunk, Nil) {
  case block {
    Code(lang, text) -> Ok(CodeChunk(lang, text))
    Paragraph(_, [FullImage(text, data), ..rest]) ->
      Ok(FigureChunk(
        src: destination(data.dest),
        alt: inline_text(text),
        caption: drop_leading_break(rest),
      ))
    _ -> Error(Nil)
  }
}

/// A caption written on the line below the image arrives as a leading soft
/// break.
fn drop_leading_break(inlines: List(Inline)) -> List(Inline) {
  case inlines {
    [SoftBreak, ..rest] -> rest
    _ -> inlines
  }
}

fn destination(dest: Destination) -> String {
  case dest {
    Absolute(uri) -> uri
    Relative(uri) -> uri
    Anchor(id) -> "#" <> id
  }
}

fn inline_text(inlines: List(Inline)) -> String {
  inlines
  |> list.map(fn(inline) {
    case inline {
      Text(text) | CodeSpan(text) -> text
      Emphasis(inner)
      | Strong(inner)
      | Strikethrough(inner)
      | Highlight(inner) -> inline_text(inner)
      FullLink(text, _) -> inline_text(text)
      SoftBreak -> " "
      _ -> ""
    }
  })
  |> string.concat
}

fn figure(
  doc: Document,
  src: String,
  alt: String,
  caption: List(Inline),
) -> Element(Nil) {
  let size =
    image.dimensions(src)
    |> result.map(fn(d) { #(d.width, d.height) })
    |> option.from_result

  let picture =
    ui.content_image(
      src: src,
      webp: option.from_result(image.webp_sibling(src)),
      alt: alt,
      size: size,
    )

  let caption = case caption {
    [] -> []
    inlines -> [
      html.figcaption(
        [],
        to_lustre.to_lustre(Document(..doc, blocks: [Paragraph("", inlines)])),
      ),
    ]
  }

  html.figure([attribute.class("post-figure")], [picture, ..caption])
}

fn code_block(lang: String, code: String) -> Element(Nil) {
  html.div([attribute.class("code-block")], [
    html.button(
      [
        attribute.class("code-copy"),
        attribute.type_("button"),
        attribute("aria-label", "Copy code"),
        attribute("data-code", code),
      ],
      [html.text("Copy")],
    ),
    html.pre([], [highlight(lang, code)]),
  ])
}

fn highlight(lang: String, code: String) -> Element(msg) {
  let attrs = [attribute("data-lang", lang)]
  case grammar_for(lang) {
    Ok(grammar) ->
      element.unsafe_raw_html("", "code", attrs, smalto.to_html(code, grammar))
    Error(_) -> html.code(attrs, [html.text(code)])
  }
}

fn grammar_for(lang: String) -> Result(Grammar, Nil) {
  case lang {
    "bash" | "sh" | "shell" -> Ok(bash.grammar())
    "json" | "jsonc" -> Ok(json.grammar())
    "ts" | "js" | "typescript" | "javascript" -> Ok(typescript.grammar())
    "yaml" | "yml" -> Ok(yaml.grammar())
    _ -> Error(Nil)
  }
}

pub fn format_date(iso: String) -> String {
  case string.split(iso, "-") {
    [year, month, day] ->
      month_name(month) <> " " <> strip_leading_zero(day) <> ", " <> year
    _ -> iso
  }
}

pub fn format_index_date(iso: String) -> String {
  case string.split(iso, "-") {
    [year, month, day] ->
      string.uppercase(month_short(month)) <> " " <> day <> ", " <> year
    _ -> iso
  }
}

fn strip_leading_zero(value: String) -> String {
  case string.starts_with(value, "0") {
    True -> string.drop_start(value, 1)
    False -> value
  }
}

fn month_name(month: String) -> String {
  case month {
    "01" -> "January"
    "02" -> "February"
    "03" -> "March"
    "04" -> "April"
    "05" -> "May"
    "06" -> "June"
    "07" -> "July"
    "08" -> "August"
    "09" -> "September"
    "10" -> "October"
    "11" -> "November"
    "12" -> "December"
    _ -> month
  }
}

fn month_short(month: String) -> String {
  string.slice(month_name(month), 0, 3)
}

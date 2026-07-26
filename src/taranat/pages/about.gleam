import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import taranat/layout
import taranat/ui

pub fn view(assets: String) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "About \u{2014} Panat Taranat",
      description: "Software engineer and co-owner of Dungeon Books, based in Jersey City.",
      path: "/about",
      kind: "website",
      image: layout.default_og_image,
    ),
    assets,
    [hero(), bookstore(), colophon(), elsewhere()],
  )
}

fn ext_link(href: String, text: String) -> Element(Nil) {
  html.a([attribute.href(href), attribute.rel("noreferrer")], [html.text(text)])
}

fn hero() -> Element(Nil) {
  html.section([attribute.class("section section--about-hero")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("about-lead")], [
        html.figure([attribute.class("about-hero__photo")], [
          ui.responsive_image(ui.Image(
            base: "/assets/panat-watercolor",
            widths: [400, 736],
            format: "jpg",
            sizes: "26rem",
            alt: "Watercolor portrait of Panat Taranat",
            width: 736,
            height: 736,
            loading: ui.Eager,
          )),
        ]),
        html.h1([attribute.class("display")], [html.text("About")]),
        html.p([attribute.class("lede")], [
          html.text(
            "I'm a software engineer based in Jersey City. In 2024 I opened Dungeon Books, a sci-fi and fantasy bookstore.",
          ),
        ]),
        html.h2([], [html.text("Dungeon Books")]),
        html.p([], [
          html.text(
            "Carrie and I met across a D&D table. A few sessions in, we were sketching what eventually became ",
          ),
          ext_link("https://dungeonbooks.com", "Dungeon Books"),
          html.text(
            ", a sci-fi and fantasy bookstore we opened in Jersey City in 2024. Carrie was a software engineer, then an ",
          ),
          ext_link("https://carrievu.com", "actor"),
          html.text(
            ", then sold books. I was a software engineer with a collection of sci-fi and fantasy paperback books that had been slowly taking over my apartment.",
          ),
        ]),
        html.p([], [
          html.text("The idea came from "),
          ext_link(
            "https://hardcover.app/@panat/lists/appendix-n-inspirational-and-educational-reading?referrer_id=148",
            "Appendix N",
          ),
          html.text(
            " in the original AD&D Dungeon Master's Guide, the reading list that inspired the people who wrote the game. The store is built around that premise: the same shelf can feed the novel you read at home and the campaign you run on Saturday. We wanted it to feel more like a friend's living room than a retail space, where someone could walk in for one book and leave with one they weren't looking for. I call it foraging for ideas.",
          ),
        ]),
      ]),
    ]),
  ])
}

fn colophon() -> Element(Nil) {
  html.section([attribute.class("section")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-text")], [
        html.h2([], [html.text("Colophon")]),
        ui.definition(
          word: "colophon",
          part_of_speech: "n.",
          meaning: "a note at the back of a book saying how it was made.",
        ),
        html.p([], [
          html.text(
            "This site is a small Gleam program that writes HTML files. There is no framework and nothing running on a server. The CSS is hand-written, and the only JavaScript is three short files: the theme toggle, the email link, and the copy buttons on code blocks. The source is on ",
          ),
          ext_link("https://github.com/ptaranat/taranat.com", "GitHub"),
          html.text("."),
        ]),
      ]),
    ]),
  ])
}

fn bookstore() -> Element(Nil) {
  html.section([attribute.class("section")], [
    html.div([attribute.class("grid")], [
      html.figure([attribute.class("about-figure")], [
        ui.responsive_image(ui.Image(
          base: "/assets/dungeonbooks-shelves",
          widths: [800, 1500],
          format: "jpg",
          sizes: "(min-width: 60rem) 65rem, 100vw",
          alt: "Shelves of sci-fi and fantasy novels and RPG books inside Dungeon Books",
          width: 1500,
          height: 1000,
          loading: ui.Lazy,
        )),
        html.figcaption([], [html.text("Inside the shop.")]),
      ]),
      html.div([attribute.class("col-span-text")], [
        html.p([], [
          html.text(
            "We run it a little differently than most indie shops. The business side gets treated like a small product: we look at what's going well, experiment, and be honest with ourselves when something isn't working out. Year one came in at 29% growth without loans or outside investors, which feels surreal to type. The part I'm prouder of, though, is that every book on our shelves was picked by a person who reads them.",
          ),
        ]),
        html.p([], [
          html.text(
            "Weekly D&D sessions in the back of the store are non-negotiable. A lot of our regulars met each other across a table of dice.",
          ),
        ]),
        html.p([], [
          html.text(
            "Outside the shop, I teach AI and technology workshops at the Jersey City Free Public Library and give presentations on technology and tabletop games at Liberty Science Center. Most of what I earn goes back into the store and the programs we run around it.",
          ),
        ]),
        html.p([attribute.class("about-press")], [
          html.span([attribute.class("about-press__label")], [
            html.text("Press:"),
          ]),
          html.text(" "),
          ext_link(
            "https://www.indiebound.org/blog-posts/dungeon-books-jersey-citys-destination-sci-fi-fantasy-and-rpgs",
            "IndieBound",
          ),
          html.text(", "),
          ext_link(
            "https://jcitytimes.com/dungeon-books-is-the-latest-addition-to-a-gaming-neighborhood-downtown/",
            "Jersey City Times",
          ),
          html.text(", "),
          ext_link(
            "https://www.shelf-awareness.com/issue.html?issue=4831#m65357",
            "Shelf Awareness",
          ),
          html.text("."),
        ]),
      ]),
      html.figure([attribute.class("about-figure")], [
        ui.responsive_image(ui.Image(
          base: "/assets/panat-carrie-storefront",
          widths: [800, 1280],
          format: "jpg",
          sizes: "(min-width: 60rem) 65rem, 100vw",
          alt: "Panat and Carrie holding a giant d20 in front of the Dungeon Books storefront",
          width: 1280,
          height: 853,
          loading: ui.Lazy,
        )),
        html.figcaption([], [
          html.text(
            "Panat and Carrie out front. Dungeon Books, Jersey City, opened 2024.",
          ),
        ]),
      ]),
    ]),
  ])
}

fn interest(label: String, links: List(Element(Nil))) -> Element(Nil) {
  html.li([], [html.strong([], [html.text(label)]), html.text(" "), ..links])
}

fn elsewhere() -> Element(Nil) {
  html.section([attribute.class("section")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-text")], [
        html.h2([], [html.text("Elsewhere")]),
        html.ul([attribute.class("about-interests")], [
          interest("Reading", [
            ext_link(
              "https://hardcover.app/@panat?referrer_id=148",
              "hardcover.app/@panat",
            ),
          ]),
          interest("Boardgames", [
            ext_link(
              "https://kallax.io/u/PXNGH-Panat",
              "kallax.io/u/PXNGH-Panat",
            ),
          ]),
          interest("Music", [
            ext_link(
              "https://www.last.fm/user/ptaranat",
              "last.fm/user/ptaranat",
            ),
          ]),
          interest("Code", [
            ext_link("https://github.com/ptaranat", "ptaranat"),
            html.text(", "),
            ext_link("https://github.com/script-wizards", "script-wizards"),
            html.text(", "),
            ext_link("https://github.com/dungeonbooks", "dungeonbooks"),
          ]),
          interest("Social", [
            ext_link("https://x.com/ptaranat", "x.com/ptaranat"),
            html.text(", "),
            ext_link(
              "https://www.linkedin.com/in/taranat",
              "linkedin.com/in/taranat",
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}

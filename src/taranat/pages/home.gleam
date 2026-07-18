import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/email
import taranat/layout

const description = "Software engineer and co-owner of Dungeon Books, a sci-fi and fantasy bookstore in Jersey City. I build distributed systems and tools for the indie-bookstore trade."

pub fn view() -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "Panat Taranat",
      description: description,
      path: "/",
      kind: "website",
      image: layout.default_og_image,
    ),
    [hero(), contact()],
  )
}

fn proof_link(href: String, label: String, text: String) -> Element(Nil) {
  html.a(
    [
      attribute.class("proof-link"),
      attribute.href(href),
      attribute.rel("noreferrer"),
      attribute("aria-label", label),
    ],
    [html.text(text)],
  )
}

fn hero() -> Element(Nil) {
  html.section([attribute.class("section section--hero")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("home-hero__text")], [
        html.h1([attribute.class("display")], [
          html.text("I write code and run a bookstore."),
        ]),
        html.p([attribute.class("lede")], [
          html.text("In 2024, Carrie and I opened "),
          html.a(
            [
              attribute.href("https://dungeonbooks.com"),
              attribute.rel("noreferrer"),
            ],
            [html.text("Dungeon Books")],
          ),
          html.text(
            ", a sci-fi and fantasy shop in Jersey City. I spent years building distributed systems and infrastructure, and I wanted to make something I could stand inside of. ",
          ),
          proof_link(
            "https://www.indiebound.org/blog-posts/dungeon-books-jersey-citys-destination-sci-fi-fantasy-and-rpgs",
            "IndieBound feature on Dungeon Books",
            "So",
          ),
          html.text(" "),
          proof_link(
            "https://www.shelf-awareness.com/issue.html?issue=4831#m65357",
            "Shelf Awareness feature on Dungeon Books",
            "we",
          ),
          html.text(" "),
          proof_link(
            "https://www.instagram.com/p/C_BjpEsP8iP/",
            "Our opening-day post on Instagram, August 2024",
            "did",
          ),
          html.text(
            ". I still code every day: software for the shop, and tools for booksellers. The rest of the week you'll find me behind the counter or running D&D nights in the back.",
          ),
        ]),
      ]),
      html.figure([attribute.class("home-hero__art")], [
        html.picture([], [
          html.source([
            attribute.type_("image/webp"),
            attribute.srcset(
              "/assets/storefront-watercolor-800.webp 800w, /assets/storefront-watercolor-1400.webp 1400w",
            ),
            attribute("sizes", "(min-width: 60rem) 40vw, 22rem"),
          ]),
          html.img([
            attribute.src("/assets/storefront-watercolor-800.jpg"),
            attribute.srcset(
              "/assets/storefront-watercolor-800.jpg 800w, /assets/storefront-watercolor-1400.jpg 1400w",
            ),
            attribute("sizes", "(min-width: 60rem) 40vw, 22rem"),
            attribute.alt(
              "Watercolor painting of the Dungeon Books storefront: a wizard-and-book sign in the window, an A-frame chalkboard on the sidewalk, and a 'Come in, we're open' sign on the door",
            ),
            attribute("width", "1500"),
            attribute("height", "2000"),
            attribute("loading", "eager"),
          ]),
        ]),
        html.figcaption([], [html.text("Dungeon Books, Jersey City.")]),
      ]),
    ]),
  ])
}

fn contact() -> Element(Nil) {
  html.section([attribute.class("section section--contact")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-text")], [
        html.h2([], [html.text("Get in touch")]),
        html.p([], [
          html.text(
            "Come by the shop, or reach me here. If you're building in or around the indie-bookstore space, I'm always up for a conversation.",
          ),
        ]),
        html.ul([attribute.class("contact-list")], [
          html.li([], [email.link()]),
          html.li([], [
            html.a([attribute.href("/meet")], [html.text("Book a call")]),
          ]),
        ]),
      ]),
    ]),
  ])
}

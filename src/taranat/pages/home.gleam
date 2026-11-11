import gleam/list
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/email
import taranat/layout
import taranat/reading.{type Shelf}
import taranat/ui

const description = "Software engineer and co-owner of Dungeon Books, a sci-fi and fantasy bookstore in Jersey City. I build distributed systems and tools for the indie-bookstore trade."

pub fn view(assets: String, shelves: List(Shelf)) -> Element(Nil) {
  layout.render(
    layout.Meta(
      title: "Panat Taranat",
      description: description,
      path: "/",
      kind: "website",
      image: layout.default_og_image,
      published: "",
    ),
    assets,
    [hero(), shelf_section(shelves), projects(), contact()],
  )
}

type Project {
  Project(
    name: String,
    kind: String,
    href: String,
    image: String,
    alt: String,
    blurb: String,
  )
}

const side_projects = [
  Project(
    "Terminal Bookstore",
    "Dungeon Books",
    "https://shop.dungeonbooks.com",
    "ssh-bookshop",
    "The Dungeon Books shop in a terminal, featuring the book club pick",
    "ssh shop.dungeonbooks.com opens our book club as a bookstore in your terminal. It takes real orders through Square, and has an API and a CLI so agents can buy books too.",
  ),
  Project(
    "Shop Docs & Policies",
    "Dungeon Books",
    "https://docs.dungeonbooks.com",
    "dungeonbooks-docs",
    "The Dungeon Books docs home page, listing store, events, orders and Dungeon Club topics",
    "docs.dungeonbooks.com has everything customers ask us, written down: hours, events, special orders, Dungeon Club memberships and the house rules. Marty reads it too.",
  ),
  Project(
    "Bookstore Discord Bot",
    "Dungeon Books",
    "https://github.com/dungeonbooks/marty",
    "marty",
    "Marty answering a question about The Dying Earth in Discord, next to his book card for it",
    "Marty is a burnt-out wizard who used to be a software engineer and now works our Discord. He recommends books, pulls up the details, and tells you where to buy them.",
  ),
  Project(
    "Hermes Memory Plugin",
    "Personal",
    "https://hermes-agent.nousresearch.com/marketplace/zeromem",
    "zeromem",
    "The zeromem banner: tokenless memory system for Hermes Agent",
    "zeromem keeps every message word for word in one SQLite file and searches it without calling a model. Written in Rust.",
  ),
  Project(
    "Pocket Hermes",
    "Personal",
    "https://github.com/ptaranat/pocket-hermes",
    "pocket-hermes",
    "A TrimUI Brick handheld running the Pocket Hermes voice client",
    "A voice client for my Hermes agent on a TrimUI Brick. C and SDL2 on the device, a small Python relay at home.",
  ),
  Project(
    "Claude Code Remote",
    "Personal",
    "https://github.com/ptaranat/pt7",
    "pt7",
    "The PT-7 phone key deck in light and dark themes: a talk pad above up, down, tab, escape and enter keys",
    "PT-7 turns your phone into a key deck: hold the big key to dictate, tap the rest to drive Claude Code from across the room. Runs on Mac, PC or Linux, with no app and no cloud.",
  ),
]

fn projects() -> Element(Nil) {
  html.section([attribute.class("section section--projects")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-full")], [
        html.h2([], [html.text("Projects")]),
        html.p([attribute.class("projects__lede")], [
          html.text("Some things I've built, for the shop and for myself."),
        ]),
        html.ul(
          [attribute.class("projects")],
          side_projects
            |> list.map(fn(project) {
              html.li([attribute.class("project")], [
                html.a(
                  [
                    attribute.class("project__link"),
                    attribute.href(project.href),
                    attribute.rel("noreferrer"),
                  ],
                  [
                    ui.responsive_image(ui.Image(
                      base: "/assets/projects/" <> project.image,
                      widths: [600, 1200],
                      format: "jpg",
                      sizes: "(min-width: 60rem) 30rem, (min-width: 40rem) 45vw, 100vw",
                      alt: project.alt,
                      width: 1200,
                      height: 630,
                      loading: ui.Lazy,
                    )),
                    html.span([attribute.class("project__kind")], [
                      html.text(project.kind),
                    ]),
                    html.span([attribute.class("project__name")], [
                      html.text(project.name),
                    ]),
                  ],
                ),
                html.p([attribute.class("project__blurb")], [
                  html.text(project.blurb),
                ]),
              ])
            }),
        ),
      ]),
    ]),
  ])
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
            ", a sci-fi and fantasy bookstore in Jersey City. We'd both spent years building software and we wanted to build something we could stand inside of. ",
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
            ". I still code every day, for the shop and for booksellers. The rest of the week I'm behind the counter or running D&D in the back.",
          ),
        ]),
      ]),
      html.div([attribute.class("home-hero__art")], [
        ui.responsive_image(ui.Image(
          base: "/assets/storefront-watercolor",
          widths: [800, 1400],
          format: "jpg",
          sizes: "(min-width: 60rem) 40vw, 22rem",
          alt: "Watercolor painting of the Dungeon Books storefront: a wizard-and-book sign in the window, an A-frame chalkboard on the sidewalk, and a 'Come in, we're open' sign on the door",
          width: 1500,
          height: 2000,
          loading: ui.Eager,
        )),
      ]),
    ]),
  ])
}

fn shelf_section(shelves: List(Shelf)) -> Element(Nil) {
  html.section([attribute.class("section section--shelves")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-full")], [reading.view(shelves)]),
    ]),
  ])
}

fn contact() -> Element(Nil) {
  html.section([attribute.class("section section--contact")], [
    html.div([attribute.class("grid")], [
      html.div([attribute.class("col-span-full home-contact")], [
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

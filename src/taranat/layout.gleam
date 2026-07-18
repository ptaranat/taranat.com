import gleam/list
import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import taranat/email

pub const site_origin = "https://taranat.com"

pub const default_og_image = "/assets/og-default.png"

pub type Meta {
  Meta(
    title: String,
    description: String,
    path: String,
    kind: String,
    image: String,
  )
}

fn resolve_image(image: String) -> String {
  case string.starts_with(image, "http") || string.starts_with(image, "//") {
    True -> image
    False -> site_origin <> image
  }
}

fn is_current(href: String, current: String) -> Bool {
  case href {
    "/" -> current == "/"
    _ -> current == href || string.starts_with(current, href <> "/")
  }
}

fn when(condition: Bool, elements: List(Element(msg))) -> List(Element(msg)) {
  case condition {
    True -> elements
    False -> []
  }
}

fn nav(current: String) -> Element(msg) {
  let items = [
    #("/", "Index"),
    #("/about", "About"),
    #("/blog", "Blog"),
    #("/meet", "Meet"),
  ]

  let links =
    list.map(items, fn(item) {
      let #(href, label) = item
      let attrs = case is_current(href, current) {
        True -> [attribute.href(href), attribute("aria-current", "page")]
        False -> [attribute.href(href)]
      }
      html.li([], [html.a(attrs, [html.text(label)])])
    })

  let toggle =
    html.li([attribute.class("site-nav__theme")], [
      html.button(
        [
          attribute.id("theme-toggle"),
          attribute.type_("button"),
          attribute("aria-label", "Toggle color scheme"),
        ],
        [],
      ),
    ])

  html.nav([attribute.class("site-nav"), attribute("aria-label", "Primary")], [
    html.ul([], list.append(links, [toggle])),
  ])
}

/// Runs before first paint so a stored preference does not flash.
const pre_body_script = "
(function(){
  try {
    var m = localStorage.getItem('user-color-scheme');
    if (m === 'light' || m === 'dark') {
      document.documentElement.setAttribute('data-user-color-scheme', m);
    }
  } catch (e) {}
})();
"

const nav_script = "(function(){
  var d = document.currentScript.previousElementSibling;
  var summary = d.querySelector('.site-nav-toggle');
  var mq = matchMedia('(min-width: 60rem)');
  var close = function(){ d.removeAttribute('open'); };
  var sync = function(){ mq.matches ? d.setAttribute('open','') : close(); };
  sync();
  mq.addEventListener('change', sync);
  summary.addEventListener('click', function(e){
    if(mq.matches) return;
    e.preventDefault();
    d.open ? close() : d.setAttribute('open','');
  });
  d.querySelectorAll('.site-nav a').forEach(function(a){
    a.addEventListener('click', function(){ if(!mq.matches) close(); });
  });
  document.addEventListener('click', function(e){
    if(!mq.matches && d.open && !d.contains(e.target)) close();
  });
  document.addEventListener('keydown', function(e){
    if(e.key === 'Escape' && !mq.matches && d.open){ close(); summary.focus(); }
  });
})();"

fn stylesheet(path: String, assets: String) -> Element(msg) {
  html.link([
    attribute.rel("stylesheet"),
    attribute.href(path <> "?v=" <> assets),
  ])
}

fn head_element(meta: Meta, assets: String) -> Element(msg) {
  let canonical = site_origin <> meta.path
  let og_image = resolve_image(meta.image)
  let has_description = meta.description != ""

  html.head(
    [],
    list.flatten([
      [
        html.meta([attribute.charset("utf-8")]),
        html.meta([
          attribute.name("viewport"),
          attribute.content("width=device-width, initial-scale=1"),
        ]),
        html.title([], meta.title),
      ],
      when(has_description, [
        html.meta([
          attribute.name("description"),
          attribute.content(meta.description),
        ]),
      ]),
      [
        html.link([attribute.rel("canonical"), attribute.href(canonical)]),
        html.meta([
          attribute("property", "og:type"),
          attribute.content(meta.kind),
        ]),
        html.meta([
          attribute("property", "og:site_name"),
          attribute.content("Panat Taranat"),
        ]),
        html.meta([
          attribute("property", "og:title"),
          attribute.content(meta.title),
        ]),
      ],
      when(has_description, [
        html.meta([
          attribute("property", "og:description"),
          attribute.content(meta.description),
        ]),
      ]),
      [
        html.meta([
          attribute("property", "og:url"),
          attribute.content(canonical),
        ]),
        html.meta([
          attribute("property", "og:image"),
          attribute.content(og_image),
        ]),
        html.meta([
          attribute.name("twitter:card"),
          attribute.content("summary_large_image"),
        ]),
        html.meta([
          attribute.name("twitter:title"),
          attribute.content(meta.title),
        ]),
      ],
      when(has_description, [
        html.meta([
          attribute.name("twitter:description"),
          attribute.content(meta.description),
        ]),
      ]),
      [
        html.meta([
          attribute.name("twitter:image"),
          attribute.content(og_image),
        ]),
        html.link([
          attribute.rel("alternate"),
          attribute.type_("application/rss+xml"),
          attribute("title", "Panat Taranat \u{2014} Blog"),
          attribute.href("/feed.xml"),
        ]),
        html.link([
          attribute.rel("preconnect"),
          attribute.href("https://fonts.googleapis.com"),
        ]),
        html.link([
          attribute.rel("preconnect"),
          attribute.href("https://fonts.gstatic.com"),
          attribute("crossorigin", ""),
        ]),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href(
            "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Literata:ital,opsz,wght@0,7..72,400;0,7..72,500;0,7..72,600;0,7..72,700;1,7..72,400&display=swap",
          ),
        ]),
        stylesheet("/styles/tokens/color.css", assets),
        stylesheet("/styles/tokens/typography.css", assets),
        stylesheet("/styles/tokens/grid.css", assets),
        stylesheet("/styles/base.css", assets),
        stylesheet("/styles/components.css", assets),
        html.link([
          attribute.rel("icon"),
          attribute.type_("image/x-icon"),
          attribute.href("/favicon.ico"),
        ]),
        html.link([
          attribute.rel("icon"),
          attribute.type_("image/png"),
          attribute("sizes", "16x16"),
          attribute.href("/favicon-16x16.png"),
        ]),
        html.link([
          attribute.rel("icon"),
          attribute.type_("image/png"),
          attribute("sizes", "32x32"),
          attribute.href("/favicon-32x32.png"),
        ]),
        html.link([
          attribute.rel("apple-touch-icon"),
          attribute("sizes", "180x180"),
          attribute.href("/apple-touch-icon.png"),
        ]),
        html.link([
          attribute.rel("manifest"),
          attribute.href("/site.webmanifest"),
        ]),
        html.meta([
          attribute.name("msapplication-config"),
          attribute.content("/browserconfig.xml"),
        ]),
        html.meta([
          attribute.name("theme-color"),
          attribute.content("#14110e"),
        ]),
        html.script([], pre_body_script),
      ],
    ]),
  )
}

fn deferred_script(path: String, assets: String) -> Element(msg) {
  html.script(
    [attribute.src(path <> "?v=" <> assets), attribute("defer", "")],
    "",
  )
}

pub fn render(
  meta: Meta,
  assets: String,
  children: List(Element(msg)),
) -> Element(msg) {
  html.html([attribute.lang("en")], [
    head_element(meta, assets),
    html.body([], [
      html.a([attribute.class("skip"), attribute.href("#main")], [
        html.text("Skip to content"),
      ]),
      html.header([attribute.class("site-header")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("site-masthead")], [
            html.a([attribute.class("site-title"), attribute.href("/")], [
              html.text("PANAT TARANAT"),
            ]),
            html.span([attribute.class("site-subtitle")], [
              html.text("Software Engineer & Bookstore Owner"),
            ]),
          ]),
          html.details([attribute.class("site-nav-wrapper")], [
            html.summary(
              [
                attribute.class("site-nav-toggle"),
                attribute("aria-label", "Toggle menu"),
              ],
              [],
            ),
            nav(meta.path),
          ]),
          html.script([], nav_script),
        ]),
      ]),
      html.main([attribute.id("main"), attribute.class("site-main")], children),
      html.footer([attribute.class("site-footer")], [
        html.div([attribute.class("grid")], [
          html.div([attribute.class("col")], [
            html.span([], [html.text("\u{00A9} 2026 Panat Taranat")]),
          ]),
          html.div([attribute.class("col")], [email.link()]),
        ]),
      ]),
      deferred_script("/js/theme.js", assets),
      deferred_script("/js/email.js", assets),
      deferred_script("/js/code-copy.js", assets),
    ]),
  ])
}

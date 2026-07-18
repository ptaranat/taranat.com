import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre/element
import lustre/ssg
import simplifile
import taranat/assets
import taranat/pages/about
import taranat/pages/blog
import taranat/pages/home
import taranat/pages/meet
import taranat/pages/not_found
import taranat/pages/post_page
import taranat/post.{type Post}
import taranat/syndication

fn add_post_routes(
  config: ssg.Config(ssg.HasStaticRoutes, dir, index),
  posts: List(Post),
  assets: String,
) -> ssg.Config(ssg.HasStaticRoutes, dir, index) {
  list.fold(posts, config, fn(acc, p) {
    ssg.add_static_route(acc, "/blog/" <> p.slug, post_page.view(p, assets))
  })
}

fn strip_runtime_markers() -> Nil {
  let assert Ok(files) = simplifile.get_files("./dist")

  use path <- list.each(list.filter(files, string.ends_with(_, ".html")))
  let assert Ok(content) = simplifile.read(path)
  let assert Ok(_) =
    content
    |> string.replace("<!-- lustre:fragment -->", "")
    |> string.replace("<!-- /lustre:fragment -->", "")
    |> string.replace("<!-- lustre:map -->", "")
    |> simplifile.write(path, _)
  Nil
}

pub fn main() {
  case build() {
    True -> Nil
    False -> panic as "build failed"
  }
}

pub fn build() -> Bool {
  let posts = post.published(post.load_all())
  let assets = assets.digest()

  let config =
    ssg.new("./dist")
    |> ssg.add_static_dir("public")
    |> ssg.add_static_route("/", home.view(assets))
    |> ssg.add_static_route("/about", about.view(assets))
    |> ssg.add_static_route("/blog", blog.view(posts, assets))
    |> ssg.add_static_route("/meet", meet.view(assets))
    |> add_post_routes(posts, assets)
    |> ssg.add_static_asset("/robots.txt", syndication.robots_txt())
    |> ssg.add_static_asset("/sitemap.xml", syndication.sitemap_xml(posts))
    |> ssg.add_static_asset("/feed.xml", syndication.feed_xml(posts))
    |> ssg.add_static_asset(
      "/404.html",
      element.to_document_string(not_found.view(assets)),
    )
    |> ssg.use_index_routes

  // add_dynamic_route ignores use_index_routes and would emit /blog/slug.html.
  case ssg.build(config) {
    Ok(_) -> {
      strip_runtime_markers()
      io.println(
        "built ./dist with " <> int.to_string(list.length(posts)) <> " posts",
      )
      True
    }
    Error(error) -> {
      io.println("build failed: " <> string.inspect(error))
      False
    }
  }
}

import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile
import taranat

const content_dirs = ["content", "public"]

const source_dir = "src"

const poll_ms = 400

const port = 3000

@external(erlang, "taranat_dev_ffi", "serve")
fn serve(port: Int, doc_root: String) -> Result(Nil, String)

pub fn main() {
  let _ = taranat.build()

  case serve(port, "./dist") {
    Ok(_) ->
      io.println(
        "serving http://localhost:"
        <> int.to_string(port)
        <> " — watching content/ and public/, ctrl-c to stop",
      )
    Error(reason) ->
      io.println("could not start dev server: " <> reason <> " (build only)")
  }
  watch(fingerprint(content_dirs), fingerprint([source_dir]))
}

fn watch(content: String, source: String) -> Nil {
  process.sleep(poll_ms)

  let next_source = fingerprint([source_dir])
  case next_source == source {
    False -> io.println("src/ changed — restart `gleam dev` to pick it up")
    True -> Nil
  }

  let next_content = fingerprint(content_dirs)
  case next_content == content {
    True -> Nil
    False -> {
      let _ = taranat.build()
      Nil
    }
  }

  watch(next_content, next_source)
}

fn fingerprint(dirs: List(String)) -> String {
  dirs
  |> list.flat_map(fn(dir) {
    case simplifile.get_files(dir) {
      Ok(files) -> files
      Error(_) -> []
    }
  })
  |> list.sort(string.compare)
  |> list.map(fn(path) {
    case simplifile.file_info(path) {
      Ok(info) ->
        path
        <> ":"
        <> int.to_string(info.size)
        <> ":"
        <> int.to_string(info.mtime_seconds)
      Error(_) -> path <> ":missing"
    }
  })
  |> string.join("\n")
}

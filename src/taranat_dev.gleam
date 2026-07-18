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

pub fn main() {
  io.println("watching content/ and public/ — ctrl-c to stop")
  let _ = taranat.build()
  watch(fingerprint(content_dirs), fingerprint([source_dir]))
}

fn watch(content: String, source: String) -> Nil {
  process.sleep(poll_ms)

  let next_source = fingerprint([source_dir])
  case next_source == source {
    False ->
      // The running process holds already-compiled code, so rebuilding here
      // would silently emit the old output.
      io.println("src/ changed — restart `gleam dev` to pick it up")
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

/// Size and mtime of every watched file. Cheap enough at this scale, and it
/// catches edits that leave the size unchanged.
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

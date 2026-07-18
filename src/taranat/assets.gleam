import gleam/bit_array
import gleam/crypto
import gleam/list
import gleam/string
import simplifile

const hashed_dirs = ["public/styles", "public/js"]

/// Cache-busting token derived from the stylesheet and script contents, so a
/// deploy that changes them serves them under a new URL.
pub fn digest() -> String {
  hashed_dirs
  |> list.flat_map(fn(dir) {
    case simplifile.get_files(dir) {
      Ok(files) -> files
      Error(_) -> []
    }
  })
  |> list.sort(string.compare)
  |> list.filter_map(simplifile.read_bits)
  |> bit_array.concat
  |> crypto.hash(crypto.Sha256, _)
  |> bit_array.base16_encode
  |> string.lowercase
  |> string.slice(0, 12)
}

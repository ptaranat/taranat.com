import gleam/list
import gleam/result
import gleam/string
import simplifile

const public_dir = "public"

pub type Dimensions {
  Dimensions(width: Int, height: Int)
}

/// Intrinsic size of a site-relative image, read from the file header so no
/// table has to be kept by hand.
pub fn dimensions(src: String) -> Result(Dimensions, Nil) {
  use bits <- result.try(read(src))
  decode(bits)
}

/// A `.webp` sitting next to the image, if one was generated for it.
pub fn webp_sibling(src: String) -> Result(String, Nil) {
  use path <- result.try(local_path(src))
  use candidate <- result.try(with_extension(path, "webp"))
  case simplifile.is_file(public_dir <> candidate) {
    Ok(True) -> Ok(candidate)
    _ -> Error(Nil)
  }
}

/// Only site-relative paths that stay inside `public` are ours to look at;
/// remote images and anything reaching upwards are left alone.
fn local_path(src: String) -> Result(String, Nil) {
  case string.starts_with(src, "/") && !string.contains(src, "..") {
    True -> Ok(src)
    False -> Error(Nil)
  }
}

fn with_extension(src: String, extension: String) -> Result(String, Nil) {
  case string.split(src, ".") {
    [] | [_] -> Error(Nil)
    parts ->
      parts
      |> list.take(list.length(parts) - 1)
      |> string.join(".")
      |> string.append("." <> extension)
      |> Ok
  }
}

fn read(src: String) -> Result(BitArray, Nil) {
  use path <- result.try(local_path(src))
  simplifile.read_bits(public_dir <> path)
  |> result.replace_error(Nil)
}

fn decode(bits: BitArray) -> Result(Dimensions, Nil) {
  case bits {
    <<
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      _chunk_length:size(32),
      0x49,
      0x48,
      0x44,
      0x52,
      width:size(32),
      height:size(32),
      _rest:bits,
    >> -> Ok(Dimensions(width, height))
    <<0xFF, 0xD8, rest:bits>> -> jpeg(rest)
    _ -> Error(Nil)
  }
}

/// Walks the JPEG marker chain until a start-of-frame segment, which is where
/// the dimensions live.
fn jpeg(bits: BitArray) -> Result(Dimensions, Nil) {
  case bits {
    // Any number of 0xFF bytes may pad the run-up to a marker.
    <<0xFF, 0xFF, rest:bits>> -> jpeg(<<0xFF, rest:bits>>)
    // Entropy-coded image data starts here, and every frame header precedes
    // it, so arriving means there is nothing left to find.
    <<0xFF, 0xDA, _rest:bits>> -> Error(Nil)
    <<0xFF, marker:size(8), rest:bits>> ->
      case is_standalone(marker) {
        True -> jpeg(rest)
        False -> segment(marker, rest)
      }
    _ -> Error(Nil)
  }
}

fn segment(marker: Int, bits: BitArray) -> Result(Dimensions, Nil) {
  case bits {
    <<length:size(16), rest:bits>> if length >= 2 ->
      case is_start_of_frame(marker) {
        True ->
          case rest {
            <<_precision:size(8), height:size(16), width:size(16), _rest:bits>> ->
              Ok(Dimensions(width, height))
            _ -> Error(Nil)
          }
        False -> {
          // The length counts itself.
          let payload = length - 2
          case rest {
            <<_skipped:bytes-size(payload), remaining:bits>> -> jpeg(remaining)
            _ -> Error(Nil)
          }
        }
      }
    _ -> Error(Nil)
  }
}

/// Markers that carry no length field: the temporary marker and the restarts.
fn is_standalone(marker: Int) -> Bool {
  marker == 0x01 || { marker >= 0xD0 && marker <= 0xD9 }
}

/// SOF0 through SOF15, minus the three markers that share the range without
/// describing a frame: DHT, JPG and DAC.
fn is_start_of_frame(marker: Int) -> Bool {
  marker >= 0xC0
  && marker <= 0xCF
  && marker != 0xC4
  && marker != 0xC8
  && marker != 0xCC
}

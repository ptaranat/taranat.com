import gleam/list
import gleam/string

/// Hex-formatted (lowercase) public key. NIP-05 forbids npub here.
pub const pubkey = "d4c6bcf9c4cf1d49a9768db7acb48a8d6704bbea309a696905a9848e4010d2df"

/// "_" is the root identifier: clients display _@taranat.com as taranat.com.
const names = ["_", "panat"]

const relays = [
  "wss://nostr.mom", "wss://relay.primal.net", "wss://offchain.pub",
  "wss://relay.damus.io", "wss://wot.nostr.party", "wss://wot.utxo.one",
  "wss://nostr.win",
]

pub fn well_known_json() -> String {
  let name_entries =
    names
    |> list.map(fn(name) { "    " <> quote(name) <> ": " <> quote(pubkey) })
    |> string.join(",\n")

  let relay_entries =
    relays
    |> list.map(fn(relay) { "      " <> quote(relay) })
    |> string.join(",\n")

  "{\n"
  <> "  \"names\": {\n"
  <> name_entries
  <> "\n  },\n"
  <> "  \"relays\": {\n"
  <> "    "
  <> quote(pubkey)
  <> ": [\n"
  <> relay_entries
  <> "\n    ]\n"
  <> "  }\n"
  <> "}\n"
}

fn quote(value: String) -> String {
  "\"" <> value <> "\""
}

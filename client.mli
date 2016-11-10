open Data

type game_state = {
  alive_players: string list;
  dead_players: string list;
}

(**
 * [get url f] will send a GET request to the URL specified by [url], parse the
 * resulting JSON into a client_json record, and pass it into [f].
 *)
val get : string -> ( client_json -> unit ) -> unit

(**
 * [post url data f] will convert [data] into a JSON string and send it to the
 * URL specified by [url] as a POST request. The resulting JSON will be parsed
 * into a client_json record and passed into [f].
 *)
val post : string -> client_json -> (client_json -> unit) -> unit

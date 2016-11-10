type game_state = {
  alive_players: string list;
  dead_players: string list;
}

(**
 * [get url f] will send a GET request to the URL specified by [url], parse the
 * resulting JSON into a data record, and pass the data into [f].
 *)
val get : string -> ( data -> unit ) -> unit

(**
 * [post url dat f] will convert [dat] into a JSON string and send it to the URL
 * specified by [url] as a POST request. The resulting JSON will be parsed into
 * a data record and passed into [f].
 *)
val post : string -> data -> (data -> unit) -> unit

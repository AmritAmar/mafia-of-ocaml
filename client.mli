open Yojson.Basic.Util

type data = {
  status_code: int;
  (* TODO *)
}

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

(**
 * Updates the chat log with the given list of strings. The list will be
 * ordered by how recent the message is (most recent to least recent).
 *)
val update_chat : string list -> unit

(**
 * Updates the display of the game state with the given game_state record.
 *)
val update_game_state : game_state -> unit

(**
 * Updates the announcements displayed, replaying the old announcements with
 * the given string.
 *)
val update_announcements : string -> unit


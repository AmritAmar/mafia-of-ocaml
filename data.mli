open Yojson.Basic.Util

type server_json = {
  day_count: int;
  game_stage: string;
  active_players: string list;
  new_announcements: string list;
  new_messages: (string * string) list;
}

type client_json = {
  player_id: string;
  player_action: string;
  arguments: string list;
}

(* Turns a server_json record into a JSON string *)
val encode_sjson : server_json -> string

(* Turns a client_json record into a JSON string *)
val encode_cjson : client_json -> string

(* Turns a JSON string into a server_json record *)
val decode_sjson : string -> server_json

(* Turns a JSON string into a client_json record *)
val decode_cjson : string -> client_json

open Yojson.Basic.Util

type server_json = {
  day_count: int;
  game_stage: string;
  active_players: string list;
  new_announcements: (string * string) list;
  new_messages: (string * string * string) list;
  timestamp: string;
}

type client_json = {
  player_id: string;
  player_action: string;
  arguments: string list;
}

(* Turn list of strings into list of json strings *)
let to_json_list = List.map (fun s -> `String s)

(* Turn list of json strings into list of strings *)
let to_str_list x = x |> to_list |> List.map to_string

let encode_sjson sj =
  `Assoc [
    ("day_count", `Int sj.day_count);
    ("game_stage", `String sj.game_stage);
    ("active_players", `List (to_json_list sj.active_players));
    ("new_announcements", `List (List.map
                                 (fun (typ,txt) -> `Assoc[("type",`String typ);
                                                          ("txt",`String txt)])
                                 sj.new_announcements));
    ("new_messages", `List (List.map
                            (fun (t,p,msg) -> `Assoc[("target",`String t);
                                                     ("player_id",`String p);
                                                     ("message",`String msg)])
                            sj.new_messages));
    ("timestamp", `String sj.timestamp);
  ]
  |> Yojson.to_string

let encode_cjson cj =
  `Assoc [
    ("player_id",         `String cj.player_id              );
    ("player_action",     `String cj.player_action          );
    ("arguments",         `List (to_json_list cj.arguments) );
  ]
  |> Yojson.to_string

let decode_sjson s =
  let j = Yojson.Basic.from_string s in
  {
    day_count = member "day_count" j |> to_int;
    game_stage = member "game_stage" j |> to_string;
    active_players = member "active_players" j |> to_str_list;
    new_announcements = member "new_announcements" j
                        |> to_list
                        |> List.map (fun n -> (member "type" n |> to_string,
                                               member "text" n |> to_string));
    new_messages = member "new_messages" j
                   |> to_list
                   |> List.map (fun n -> (member "target" n |> to_string,
                                          member "player_id" n |> to_string,
                                          member "message" n |> to_string));
    timestamp = member "timestamp" j |> to_string;
  }

let decode_cjson s =
  let j = Yojson.Basic.from_string s in
  {
    player_id = member "player_id" j |> to_string;
    player_action = member "player_action" j |> to_string;
    arguments = member "arguments" j |> to_str_list;
  }

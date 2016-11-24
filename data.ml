open Yojson.Basic.Util

type server_json = {
  day_count: int;
  game_stage: string;
  active_players: string list;
  new_announcements: string list;
  new_messages: string list;
}

type client_json = {
  player_id: int;
  player_action: string;
  arguments: string list;
}

(* Turn list of strings into list of json strings *)
let convert_list = List.map (fun s -> `String s)

let encode_sjson sj =
  `Assoc [
    ("day_count",         `Int sj.day_count                         );
    ("game_stage",        `String sj.game_stage                     );
    ("active_players",    `List (convert_list sj.active_players)    );
    ("new_announcements", `List (convert_list sj.new_announcements) );
    ("new_messages",      `List (convert_list sj.new_messages)      );
  ]
  |> to_string

let encode_cjson cj =
  `Assoc [
    ("player_id",         `Int cj.player_id                 );
    ("player_action",     `String cj.player_action          );
    ("arguments",         `List (convert_list cj.arguments) );
  ]
  |> to_string



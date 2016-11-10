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

open Data

module Str_set = Set.Make(String)

type client_state = {
  mutable player_id: string;
  mutable room_id: string;
  mutable day_count: int;
  mutable game_stage: string;
  mutable alive_players: Str_set.t;
  mutable dead_players: string list;
  mutable timestamp: string;
  mutable msgs: (string * string * string) list;
  mutable announcements: (string * string) list;
}

let update_players cs active_set =
  (if cs.game_stage = "Lobby"
  then cs.dead_players <- []
  else cs.dead_players <- Str_set.(diff cs.alive_players active_set |> elements)
                          @ cs.dead_players);
  cs.alive_players <- active_set

let update_client_state (cs:client_state) (sj:server_json) =
  let active_set = Str_set.of_list sj.active_players in
  let new_gs = cs.day_count <> sj.day_count
               || cs.game_stage <> sj.game_stage
               || not (Str_set.equal cs.alive_players active_set)
  in
  cs.day_count <- sj.day_count;
  cs.game_stage <- sj.game_stage;
  update_players cs active_set;
  cs.timestamp <- sj.timestamp;
  cs.msgs <- sj.new_messages @ cs.msgs;
  cs.announcements <- sj.new_announcements @ cs.announcements;
  (new_gs,sj.new_messages <> [],sj.new_announcements <> [])

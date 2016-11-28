open Data

type client_state = {
  mutable player_id: string;
  mutable room_id: string;
  mutable day_count: int;
  mutable game_stage: string;
  mutable alive_players: string list;
  mutable dead_players: string list;
  mutable timestamp: string;
  mutable msgs: (string * string) list;
  mutable announcements: string list;
}

(**
 * [update_players cs active] will update [cs] with the given list of
 * active players.
 *)
val update_players : client_state -> string list -> unit

(**
 * [update_client_state cs sj] will update [cs] with the info in the given
 * server_json record and return a tuple [(new_gs,new_msgs,new_a)], where
 * [new_gs] is whether day_count, game_stage, alive_players, or dead_players
 * has been updated, [new_msgs] is whether msgs has been updated, and [new_a]
 * is whether announcements has been updated.
 *)
val update_client_state : client_state -> server_json -> (bool * bool * bool)

(**
 * [get_recent_announcements cs] will return the most recent announcements in
 * [cs], sorted from most recent to least recent.
 *)
val get_recent_announcements : client_state -> string list

(**
 * [get_recent_msgs cs] will return the most recent messages in [cs], sorted
 * from most recent to least recent.
 *)
val get_recent_msgs : client_state -> (string * string) list

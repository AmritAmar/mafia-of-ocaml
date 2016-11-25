type game_state = {
  alive_players: string list;
  dead_players: string list;
  last_msg_time: string;
  msgs: string list;
}

(**
 * [update_players gs active] will return an instance of gs updated with the
 * given list of active players.
 *)
val update_players : game_state -> string list -> game_state

(**
 * [update_msgs gs timestamp new_msgs] will return an instance of gs updated
 * with the given timestamp and list of new messages.
 *)
val update_msgs : game_state -> string -> string list -> game_state

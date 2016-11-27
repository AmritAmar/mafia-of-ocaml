type client_state = {
  mutable player_id: string;
  mutable room_id: string;
  mutable alive_players: string list;
  mutable dead_players: string list;
  mutable timestamp: string;
  mutable msgs: string list;
  mutable announcements: string list;
}

(**
 * [update_players gs active] will return an instance of gs updated with the
 * given list of active players.
 *)
val update_players : client_state -> string list -> client_state

(**
 * [update_msgs gs timestamp new_msgs] will return an instance of gs updated
 * with the given timestamp and list of new messages.
 *)
val update_msgs : client_state -> string -> string list -> client_state

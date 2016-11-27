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

let update_players cs active =
  (if cs.alive_players <> []
   then cs.dead_players <- (List.filter (fun x -> not (List.mem x active))
                                        cs.alive_players)
                           @ cs.dead_players);
  cs.alive_players <- active

let update_msgs cs ts new_msgs =
  cs.timestamp <- ts;
  cs.msgs <- new_msgs @ cs.msgs

let update_client_state cs sj =
  failwith "Unimplemented"

let get_recent_announcements cs =
  failwith "Unimplemented"

let get_recent_msgs cs =
  failwith "Unimplemented"

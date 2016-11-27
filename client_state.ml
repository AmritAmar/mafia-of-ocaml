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

let update_client_state cs sj =
  cs.day_count <- sj.day_count;
  cs.game_stage <- sj.game_stage;
  update_players cs sj.active_players;
  cs.announcements <- sj.new_announcements @ cs.announcements;
  cs.msgs <- sj.new_messages @ cs.msgs;

let get_recent_announcements cs =
  failwith "Unimplemented"

let get_recent_msgs cs =
  failwith "Unimplemented"

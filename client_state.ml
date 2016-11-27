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
  failwith "Unimplemented"

let update_msgs cs timestamp new_msgs =
  failwith "Unimplemented"

let update_client_state cs sj =
  failwith "Unimplemented"

let get_recent_announcements cs =
  failwith "Unimplemented"

let get_recent_msgs cs =
  failwith "Unimplemented"

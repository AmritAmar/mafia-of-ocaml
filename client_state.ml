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

(* returns a string list that has no strings > n characters long *)
let rec truncate_list n lst =
  match lst with
  | [] -> []
  | h::t -> if String.length h <= n then h::(truncate_list n t)
            else
              let first_n = String.sub h 0 n in
              let rest = String.sub h n (String.length h - n) in
              first_n::(truncate_list n (rest::t))

let update_client_state (cs:client_state) (sj:server_json) =
  cs.day_count <- sj.day_count;
  cs.game_stage <- sj.game_stage;
  update_players cs sj.active_players;
  (* TODO: truncate announcements and msgs *)
  cs.announcements <- sj.new_announcements @ cs.announcements;
  cs.msgs <- sj.new_messages @ cs.msgs

(* get top n elements of list *)
let rec select_top n lst =
  if n = 0 then []
  else match lst with
       | []   -> []
       | h::t -> h::(select_top (n-1) t)

let get_recent_announcements cs =
  select_top 10 cs.announcements

let get_recent_msgs cs =
  select_top 10 cs.msgs

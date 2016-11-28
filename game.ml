open Yojson.Basic.Util
open Str
open Data
open Core

type player_name = string
type chat_message = string
type announcement = string
type timestamp = Core.Time.t
type role = Innocent | Mafia | Dead
type game_stage = Night | Discussion | Voting | Game_Over

(** [state] is the game state of the mafia_of_ocaml game *)
type game_state = {
	day_count : int;
	stage : game_stage;
	players : (player_name * role) list;
	announcement_history : (timestamp * announcement) list
}

(*
 * Assign roles to players
 * 1/4 of the players become a member of the Mafia
 *)
let rec assign_roles counter assigned players num_players= 
    match players with 
    [] -> assigned
    | h::t -> if (counter > num_players/4) then 
        assign_roles (counter+1) ((h,Innocent)::assigned) t num_players
    else  assign_roles (counter+1) ((h,Mafia)::assigned) t num_players

(*
 * Assumes j is list of players, 1/4 of players becomes mafia
 *)
let init_state lst = 
    {day_count = 0; stage = Discussion;
        players = assign_roles 0 [] lst (List.length lst); 
        announcement_history = []}

let kill_player p pl =
    List.map (fun (x,y) -> if x=p then (x,Dead) else (x,y)) pl

(*
 * Executes player that at least half of the players
 * vote on
 *)
let handle_vote (st:game_state) (players:player_name list)  =
    let p = List.sort String.compare players in 
    let rec voting (player:string) (acc:int) (pl: player_name list) = (
        match pl with
        [] -> ""
        | h::t -> if h = player then (if (acc+1) >= (List.length p)/2
                  then h else voting player (acc+1) t)
                  else voting h 1 t) in
    let voted = voting "" 0 p in
    if voted <> "" then 
    let voted_player = List.filter (fun (x,_) -> x <> voted) st.players in
    let (_,voted_role) = List.hd voted_player in
        (if voted_role = Innocent then
        {day_count = st.day_count; stage = st.stage; 
         players = kill_player voted st.players; 
         announcement_history = (Time.now (),
            "Sadly, "^voted^" was voted guilty and has been executed.\n"^
            voted^" was an Innocent citizen.")
             ::st.announcement_history}
        else
        {day_count = st.day_count; stage = st.stage; 
         players = kill_player voted st.players;  
         announcement_history = (Time.now (),
            voted^" was voted guilty and has been executed.\n"^
            voted^" was a Mafia! Nice work!")
             ::st.announcement_history})
    else 
        {day_count = st.day_count; stage = st.stage; 
         players = st.players; 
         announcement_history = (Time.now (),
             "No majority vote has occured. No one is being executed.")
             ::st.announcement_history}

(*
 * Checks if the game has ended:
 * Game ends if either - everyone is innocent or everyone is mafia
 *)
let end_check (players : (player_name * role) list) = 
    (List.fold_left (fun a (_,x)-> (x = Mafia) || a) false players) <>
    (List.fold_left (fun a (_,x)-> (x = Innocent) || a) false players)

(** returns whether or not player is a mafia
 *)
let is_mafia player state = 
    if List.assoc player state.players = Mafia then true else false

(** returns whether or not player is alive
 *)
let is_alive player state =
    if List.assoc player state.players <> Dead then true else false

let night_to_disc st updates = 
    (* Only adds to list_killed if player is mafia*)
    let list_killed = (List.fold_left 
        (fun a x -> if (is_mafia x.player_id st) then x.arguments@a else a)
         [] updates) in
    let updated_players = 
        List.fold_left (fun a x -> kill_player x a) st.players list_killed in
    {day_count = st.day_count+1; stage = Discussion; 
        players = updated_players; 
        announcement_history = (Time.now (),
             "Good Morning! Last night,"^(String.concat ", " list_killed)^
             "were killed in their sleep by the Mafia :( RIP.")
             ::st.announcement_history}

(*
 * Assumes it only receives chats during disc
 *)
let disc_to_voting st updates = 
    {day_count = st.day_count; stage = Voting; 
        players = st.players; 
        announcement_history = (Time.now (),
             "Discussion time is now over. \n"^
             "Please vote on a player that could be a member of the Mafia.")
             ::st.announcement_history}

(*
 * Assumes people only vote once
 *)
let voting_to_night st updates = 
    let s = handle_vote st 
        (List.fold_left 
            (fun a x -> if(x.player_action = "vote") then x.arguments@a else a)
             [] updates) in
    {day_count = s.day_count; stage = Night; 
        players = s.players; 
        announcement_history = (Time.now (),
             "Its night time now - go sleep unless you have someone to visit :)")
             ::s.announcement_history}

let string_of_stage = function 
    | Night -> "Night"
    | Discussion -> "Discussion"
    | Voting -> "Voting"
    | Game_Over -> "Game Over"

let can_chat state player =
    match state.stage with
    | Voting | Game_Over -> false
    | Discussion -> is_alive player state
    | Night -> is_mafia player state

let can_vote state player =
    match state.stage with
    | Voting -> is_alive player state
    | Night -> is_mafia player state
    | _ -> false

(** [disconnect_player] disconencts player given game state and player name
 *)
let disconnect_player state player =
    {day_count = state.day_count; stage = state.stage; 
        players = kill_player player state.players; 
        announcement_history = (Time.now (),
             "Player "^player^" has disconnected.")
             ::state.announcement_history}

(** [time_span] returns the appropriate Time.span according to given state
 *)
let time_span state = 
    match state.stage with
    | Voting -> Core.Time.Span.minute
    | Game_Over -> Core.Time.Span.second
    | Discussion -> Core.Time.Span.minute
    | Night -> Core.Time.Span.minute

(*
 * TODO: 1. how to collect/handle requests from clients in a timely manner? 
 * 2. chat handling
 * 3. resolve assumptions
 *)
let step_game st updates = 
    (* maybe not most fluent game play if end check is here *)
    if end_check st.players then st else 
    match st.stage with 
    Night -> night_to_disc st updates
    | Discussion -> disc_to_voting st updates
    | Voting -> voting_to_night st updates
    | Game_Over -> st (* What to do in game_over? *)

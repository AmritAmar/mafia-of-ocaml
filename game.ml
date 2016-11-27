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
let init_state s = 
    let j = Yojson.Basic.from_string s in
    let p = Core.Std.List.permute (j |> member "players" |> to_list |> filter_string) in
    {day_count = 0; stage = Discussion;
        players = assign_roles 0 [] p (List.length p); 
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

(*
 * Assumes it only receives killing messages from mafias
 *)
let night_to_disc st updates = 
    (* would this be a list? or would only one person be killed?*)
    let list_killed = (List.fold_left (fun a x -> x.arguments@a) [] updates) in
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
 * Assumes it only receives votes during voting, and people only vote once
 *)
let voting_to_night st updates = 
    let s = handle_vote st 
        (List.fold_left (fun a x -> x.arguments@a) [] updates) in
    {day_count = s.day_count; stage = Night; 
        players = s.players; 
        announcement_history = (Time.now (),
             "Its night time now - go sleep unless you have someone to visit :)")
             ::s.announcement_history}

(*
 * TODO: 1. how to collect/handle requests from clients in a timely manner? 
 * 2. Timer for each stage? 
 * 3. chat handling
 * 4. resolve assumptions
 *)
let step_game st updates = 
    (* maybe not most fluent game play if end check is here *)
    if end_check st.players then st else 
    match st.stage with 
    Night -> night_to_disc st updates
    | Discussion -> disc_to_voting st updates
    | Voting -> voting_to_night st updates
    | Game_Over -> st
    

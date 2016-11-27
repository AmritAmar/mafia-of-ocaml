open Core.Std
open Data

type player_name = string
type chat_message = string
type announcement = string
type timestamp = Time.t
type role = Innocent | Mafia | Dead
type game_stage = Night | Discussion | Voting | Game_Over

(** [state] is the game state of the mafia_of_ocaml game *)
type game_state = {
	day_count : int;
	stage : game_stage;
	players : (player_name * role) list;
	announcement_history : (timestamp * announcement) list
}

let init_state j = 
    failwith "unimplemented"

let handle_vote st players =
    failwith "unimplemented"

let handle_message st chat_log =
    failwith "unimplemented"

let night_to_disc st updates = 
    failwith "unimplemented"

let disc_to_voting st updates = 
    failwith "unimplemented"

let voting_to_night st updates = 
    failwith "unimplemented"

let step_game st updates = 
    failwith "unimplemented"
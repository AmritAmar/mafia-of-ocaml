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


(** [init_state] is the initial state of the game as
 * determined by JSON data object [j] *)
val init_state : string list -> game_state

(** [can_chat] determines whether a player can chat in this game state
 *)
val can_chat : game_state -> player_name -> bool

(** [can_vote] determines whether a player can vote in this game state
 *)
val can_vote : game_state -> player_name -> bool

(** [disconnect_player] disconencts player given game state and player name
 *)
val disconnect_player : game_state -> player_name -> game_state

(** [time_span] returns the appropriate Time.span according to given state
 *)
val time_span : game_state -> Core.Time.Span.t

(** [handle_vote] handles players votes during Voting stage to alter the state 
  * of the game *)
val handle_vote : game_state -> player_name list -> game_state

(** [night_to_disc] processes game state changes when going from night stage 
  * to discussion stage*)
val night_to_disc : game_state -> client_json list -> game_state

(** [disc_to_voting] processes game state changes when going from disc stage 
  * to voting stage *)
val disc_to_voting : game_state -> client_json list -> game_state

(** [voting_to_night] processes game state changes when going from voting 
  * stage to night stage *)
val voting_to_night : game_state -> client_json list -> game_state

(** [step_game] steps game to the next stage, returning a new state for the 
  * next stage *)
val step_game : game_state -> client_json list -> game_state


(** [string_of_stage] is the string that represents the given game stage. *)
val string_of_stage : game_stage -> string 
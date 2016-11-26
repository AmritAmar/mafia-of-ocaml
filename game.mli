open Data

type player_name = string
type chat_message = string
type announcement = string
type timestamp = string
type role = Innocent | Mafia | Dead
type game_stage = Night | Discussion | Voting | Game_Over

(** [state] is the game state of the mafia_of_ocaml game *)
type game_state = {
	day_count : int;
	stage : game_stage;
	players : (player_name * role) list;
	chat_history : (timestamp * chat_message) list ;
	announcement_history : (timestamp * announcement) list
}

(** [init_state] is the initial state of the game as
 * determined by JSON data object [j] *)
val init_state : string -> game_state

(** [handle_vote] handles players votes during Voting stage to alter the state 
  * of the game *)
val handle_vote : game_state -> player_name list -> game_state

(** [handle_message] handles incoming chat from players*)
val handle_message :  game_state -> chat_message list -> game_state

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

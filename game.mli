open data

type role
type player_name
type chat_message
type announcement

(** [state] is the game state of the mafia_of_ocaml game *)
type state = {
	day_count : int;
	game_stage = Night | Discussion | Voting | Game_over;
	players : player_name * role;
	roles = Innocent | Mafia | Dead ;
	chat_history : (timestamp * chat_message) list ;
	announcement_history : (timestamp * announcement) list
}

(** [init_state] is the initial state of the game as
 * determined by JSON data object [j] *)
val init_state : string -> state

(** [handle_vote] handles players votes during Voting stage to alter the state 
  * of the game *)
val handle_vote : state -> player_name list -> state

(** [handle_message] handles incoming chat from players*)
val handle_message :  state -> chat_message list -> state

(** [night_to_disc] processes game state changes when going from night stage 
  * to discussion stage*)
val night_to_disc : state -> client_json list -> state

(** [disc_to_voting] processes game state changes when going from disc stage 
  * to voting stage *)
val disc_to_voting : state -> client_json list -> state

(** [voting_to_night] processes game state changes when going from voting 
  * stage to night stage *)
val voting_to_night : state -> client_json list -> state

(** [step_game] steps game to the next stage, returning a new state for the 
  * next stage *)
val step_game : state -> client_json list -> state

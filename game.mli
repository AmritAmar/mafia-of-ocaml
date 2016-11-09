open Yojson.Basic.Util

type state = {
	(*TODO*)
}

(** [init_state j] is the initial state of the game as
 * determined by JSON object [j] *)
val init_state : string -> state

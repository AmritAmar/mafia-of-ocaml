
(* TODO: Fix server.mli *)

(*
open Core.Std
open Cohttp
open Cohttp_async
open Game

type room_id = string

(** [games] is an association list mapping current room ids to 
  * game states*)
type games = room_id * state list

(** [create_room] creates a room given a cohttp request and async body *)
val create_room : games -> Cohttp.Request.t ->  Cohttp_async_body.t -> games

(** [join_room] adds a player to a room given a cohttp request and 
  * async body *)
val join_room : games -> Cohttp.Request.t ->  Cohttp_async_body.t -> games

(** [player_action] updates a game state according to player action
  * returns games *)
val player_action : games -> Cohttp.Request.t ->  Cohttp_async_body.t -> games

(** [room_status] updates a game state according to player action and 
  * returns a state *)
val room_status : games -> Cohttp.Request.t ->  Cohttp_async_body.t -> state
	
(**
 * [server] is a simple cohttp server that outputs back request information.
 *)
val server : conn -> Cohttp.Request.t -> Cohttp_async_body.t -> (Cohttp.Response.t * Cohttp_async_body.t) Async.t
*)

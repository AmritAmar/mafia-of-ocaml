open Core.Std
open Async.Std
open Cohttp 
open Cohttp_async 

open Data 
open Game 

type lobby_state = {
    admin : string;
    players : (string * bool) list; 
}

type server_state = 
   | Lobby of lobby_state 
   | Game of game_state  

type chat_message = (channel * player_name * string)
and channel = General | Mafia 

type room_data = {
    state: server_state;  
    transition_at: timestamp option; 
    last_updated: (string * timestamp) list;  
    chat_buffer: (timestamp * chat_message) list;
    action_buffer: (timestamp * client_json) list;
}

type action_bundle = {id: string; rd: room_data; cd: client_json}
exception Action_Error of (Server.response Deferred.t) 

(* [daemon_action conn req body] is a manual trigger for the server 
 * daemon process.*)
val daemon_action: 'a -> Request.t -> Body.t -> Server.response Deferred.t

(* [create_room conn req body] creates a new game room using the supplied
 * information, given that it is valid. *)
val create_room: 'a -> Request.t -> Body.t -> Server.response Deferred.t

(* [join_room conn req body] adds the player to their chosen room, if their 
 * configuration is valid. *)
val join_room: 'a -> Request.t -> Body.t -> Server.response Deferred.t

(* [player_action conn req body] applies the supplied player_action 
 * to the game state if it is valid *)
val player_action: 'a -> Request.t -> Body.t -> Server.response Deferred.t

(* [room_status conn req body] fetches the current room status. *)
val room_status: 'a -> Request.t -> Body.t -> Server.response Deferred.t

(* [handler body conn req] routes all incoming requests to the 
 * appropriate endpoints *)
val handler: body:Body.t -> 'a -> Request.t -> Server.response Deferred.t

(* [start_server] starts the server on the given port *)
val start_server: int -> unit -> 'a Deferred.t
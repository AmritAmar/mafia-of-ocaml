open Core.Std
open Async.Std
open Cohttp_async 

open Data 
open Game 
open Ringbuffer

type lobby_state = {
    admin_name : string;
    players : (string * bool) list; 
}

type server_state = 
   | Lobby of lobby_state 
   | Game of game_state  

type room_data = {
    mutable state: server_state; 
    chat_buffer: (timestamp * chat_message) ArrayBuffer.t;
    action_buffer: client_json ArrayBuffer.t; 
}

let rooms = String.Table.create () 

(* [extract_id req] returns the value of the query 
 * param "room_id" if it is present and well formed.
 * Requires: query param is in form /?room_id={x}
 * Returns: Some x if well formed, None otherwise)
 *) 

let extract_id req = 
    let uri = Cohttp.Request.uri req in 
    Uri.get_query_param uri "room_id"

let create_room conn req body = 
    let id = extract_id req in
    match id with 
        | None -> 
            Server.respond_with_string ~code:`Bad_request "Invalid room_id" 
        | Some s when Hashtbl.mem rooms s -> 
            Server.respond_with_string ~code:`Conflict "Room already exists." 
        | Some s -> 
            let room = {
                state = Lobby {admin_name = ""; players = []};
                chat_buffer = ArrayBuffer.make 3110;
                action_buffer = ArrayBuffer.make 3110; 
            } in 
            Hashtbl.replace rooms s room; 
            Server.respond_with_string  ~code:`Created "Room created."

let join_room conn req body = 
    (*
        extract the room id 
        if the room exists
            is the user first?
                give them admin rights
            get their name 
            return ok 
        else
            return a 400 error
    *)
    
    failwith "unimplemented"

let player_action conn req body = 
    failwith "unimplemented"

let room_status conn req body = 
    failwith "unimplemented"

let handler ~body:body conn req =
    let uri = Cohttp.Request.uri req in 
    let verb = Cohttp.Request.meth req in 
    match Uri.path uri, verb with
        | "/create_room", `POST -> create_room conn req body
        | "/join_room", `POST ->  join_room conn req body 
        | "/player_action", `POST -> player_action conn req body
        | "/room_status", `GET -> room_status conn req body 
        | _ , _ ->
            Server.respond_with_string ~code:`Not_found "Invalid Route."

let start_server port () = 
    eprintf "Starting mafia_of_ocaml...\n"; 
    eprintf "~-~-~-~-~-~-~~-~-~-~-~-~-~~-~-~-~-~-~-~~-~-~-~-~-~-~\n";
    eprintf "Listening for HTTP on port %d\n" port; 
    Cohttp_async.Server.create ~on_handler_error:`Raise 
        (Tcp.on_port port) handler
    >>= fun _ -> Deferred.never ()

let () = 
    Command.async
        ~summary: "Start a hello world Async Server"
        Command.Spec.(empty +> 
            flag "-p" (optional_with_default 3110 int)
                ~doc: "int Source port to listen on"
            ) start_server 
        |> Command.run 
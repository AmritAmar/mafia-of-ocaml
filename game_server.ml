open Core.Std
open Async.Std
open Cohttp_async 

open Data 
open Game 

let extract_id req = 
    let uri = Cohttp.Request.uri req in 
    let lst = Uri.get_query_param uri "room_id" in 
    match lst with 
        | None -> None 
        | h::t when List.length lst > 1 -> None 
        | h::t -> h  

let create_room conn req body = 
    (* extract the room id 
        if there is no binding for the id 
            make an empty room 
            return a created response 
        if there is
            return a conflict error 
    *)
        
    failwith "unimplemented"

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
    eprintf "~-~-~-~-~-~-~~-~-~-~-~-~-~\n";
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
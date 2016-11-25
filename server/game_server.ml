open Core.Std
open Async.Std
open Cohttp_async 

let handler ~body:_ _sock req =
    let uri = Cohttp.Request.uri req in 
    let verb = Cohttp.Request.meth req in 
    match Uri.path uri, verb with
        | "/create_room", `POST ->
            Server.respond_with_string ~code:`Not_found "Room Created!"
        | "/join_room", `POST -> 
            Server.respond_with_string ~code:`Not_found "Room Joined!"
        | "/player_action", `POST ->
            Server.respond_with_string ~code:`Not_found "Player Action:"
        | "/room_status", `GET ->
            Server.respond_with_string ~code:`Not_found "Room Status:"
        | _ , _ ->
            Server.respond_with_string ~code:`Not_found "Invalid Route."

let start_server port () = 
    eprintf "Starting mafia_of_ocaml...\n"; 
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
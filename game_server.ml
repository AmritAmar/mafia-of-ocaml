open Core.Std
open Async.Std
open Cohttp_async 

open Data 
open Game 
open Ringbuffer

type lobby_state = {
    admin : string;
    players : (string * bool) list; 
}

type server_state = 
   | Lobby of lobby_state 
   | Game of game_state  

type room_data = {
    state: server_state; 
    chat_buffer: (timestamp * string * string) list;
    action_buffer: (timestamp * client_json) list;
}

type action = {id: string; rd: room_data; cd: client_json}
exception Action_Error of (Server.response Deferred.t) 

let rooms = String.Table.create () 


(* [extract_id req] returns the value of the query 
 * param "room_id" if it is present and well formed.
 * Requires: query param is in form /?room_id={x}
 * Returns: Some x if well formed, None otherwise)
 *) 

let extract_id req = 
    let uri = Cohttp.Request.uri req in 
    Uri.get_query_param uri "room_id"

(* room creation logic *)
(* TODO: Rewrite Using Exceptions *)
(* -------------------------------------------------------- *)

(* [room_op req op] passes the room information matching the room_id in [req]
 * to [op] if it exists. Returns Bad_Request if the room_id is malformed 
 * or the room doesn't exist.*)

let room_op req op =
    let id = extract_id req in 
    match id with 
        | None -> 
            Server.respond_with_string ~code: `Bad_request "Malformed room_id."
        | Some s when not (Hashtbl.mem rooms s) -> 
            Server.respond_with_string ~code: `Bad_request "Room doesn't exist."
        | Some s ->
            let room_data = Hashtbl.find_exn rooms s in op s room_data 

let create_room conn req body = 
    let id = extract_id req in
    match id with 
        | None -> 
            Server.respond_with_string ~code:`Bad_request "Malformed room_id" 
        | Some s when Hashtbl.mem rooms s -> 
            Server.respond_with_string ~code:`Bad_request "Room already exists." 
        | Some s -> 
            let room = {
                state = Lobby {admin = ""; players = []};
                chat_buffer = [];
                action_buffer = []; 
            } in 
            Hashtbl.replace rooms s room; 
            Server.respond_with_string  ~code:`OK "Room created."


let join_room conn req body = 
    let add_player s l =  
        let in_use = List.fold ~init:false ~f:(fun acc (n,_) -> (n = s) || acc) l.players in 
        let too_long = String.length s >= 20 in 

        if (in_use || too_long) then None 
        else if l.players = [] then 
            Some {l with admin = s; players = [(s,true)]}
        else 
            Some {l with players = (s,false)::l.players}
    in 

    let join body = 
        try 
            let cd = decode_cjson body in 
            let lobby_op id rd = 
                match rd.state with 
                    | Game _ ->
                        Server.respond_with_string ~code: `Bad_request "Game already in progress."
                    | Lobby l ->
                    let result = add_player (cd.player_id) (l) in 
                    (match result with 
                        | None -> 
                            Server.respond_with_string ~code: `Bad_request  "player_id in use."
                        | Some l' ->
                            Hashtbl.replace rooms id {rd with state = Lobby l'}; 
                            Server.respond_with_string ~code: `OK "Joined!")  
            in 
            room_op (req) (lobby_op)
        with _ -> Server.respond_with_string ~code: `Bad_request "Malformed client_action.json"

    in 

    Body.to_string body >>= join 
(* -------------------------------------------------------- *)

let load_room req cd = 
    let id = extract_id req in 
    match id with 
        | None -> 
            raise (Action_Error (Server.respond_with_string ~code: `Bad_request "Malformed room_id."))
        | Some s when not (Hashtbl.mem rooms s) -> 
            raise (Action_Error (Server.respond_with_string ~code: `Bad_request "Room doesn't exist."))
        | Some s ->
            let room_data = Hashtbl.find_exn rooms s in {id = s; rd = room_data; cd = cd}

let in_room ab =
    let {id; rd; cd} = ab in 
    let pn = cd.player_id in 
    let in_room = match rd.state with 
                    | Lobby ls ->
                        List.fold ~init:false ~f:(fun acc (n,_) -> (pn = n) || acc) ls.players
                    | Game gs -> 
                        List.fold ~init:false ~f:(fun acc (n,_) -> (pn = n) || acc) gs.players
    in

    if in_room then ab
    else 
        raise (Action_Error (Server.respond_with_string ~code: `Bad_request (pn ^ " is not in room " ^ id)))

let can_chat ab = 
    let {id; rd; cd} = ab in 
    let pn = cd.player_id in 
    let can_chat = match rd.state with 
                    | Lobby ls -> true 
                    | Game gs -> 
                        (* check if the player is alive *)
                        (* check if we can chat in this game state *)
                        failwith "unimplemented" 
    in 

    if can_chat then ab 
    else 
        raise (Action_Error (Server.respond_with_string ~code:`Bad_request "Cannot Currently Chat"))

let write_chat {id; rd; cd} = 
    let pn = cd.player_id in 
    let msg = List.fold ~init:"" ~f:(^) cd.arguments in 
    let addition = ((Time.now ()), pn, msg) in 
    Hashtbl.set rooms id {rd with chat_buffer = (addition :: rd.chat_buffer)};
    Server.respond_with_string ~code: `OK "Done."

let write_ready {id; rd; cd} = 
    
    let update_players acc (n,s) = 
        if n = cd.player_id then (n,true)::acc 
                            else (n,s)::acc 
    in 
    
    match rd.state with 
        | Game _ -> raise (Action_Error (Server.respond_with_string ~code:`Bad_request "Cannot Ready in Game."))
        | Lobby ls ->
            let pl' = List.fold ~init:[] ~f:update_players ls.players in 
            Hashtbl.set rooms id {rd with state = Lobby {ls with players = pl'}}; 
            Server.respond_with_string ~code: `OK "Done."

let is_admin {id; rd; cd} = 
    failwith "unimplemented"

let all_ready {id; rd; cd} =
     failwith "unimplemented"

let write_game {id; rd; cd} = 
    failwith "unimplemented"

let can_vote {id; rd; cd} = 
    failwith "unimplemented"

let write_vote {id; rd; cd} = 
    failwith "unimplemented"

let player_action conn req body = 
    let action body = 
        try 
            let cd = decode_cjson body in
            let ab = load_room req cd |> in_room in  
            match cd.player_action with 
                | "chat" -> ab |> can_chat |> write_chat 
                | "ready" -> ab |> write_ready  
                | "start" -> ab |> is_admin |> all_ready |> write_game 
                | "vote" -> ab |> can_vote |> write_vote 
                | _ -> Server.respond_with_string ~code: `Bad_request "Invalid Command"
        with 
            | Action_Error response -> response  
            | _ -> Server.respond_with_string ~code: `Bad_request "Malformed client_action.json"
    in

    Body.to_string body >>= action

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
open Core.Std
open Async.Std
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

type room_data = {
    state: server_state;  
    transition_at: timestamp option; 
    last_updated: (string * timestamp) list;  
    chat_buffer: (timestamp * string * string) list;
    action_buffer: (timestamp * client_json) list;
}

type action_bundle = {id: string; rd: room_data; cd: client_json}
exception Action_Error of (Server.response Deferred.t) 

let rooms = String.Table.create () 

(* [respond code msg] is an alias for Server.respond_with_string *)
let respond code msg = Server.respond_with_string ~code:code msg 

(* [extract_id req] returns the value of the query 
 * param "room_id" if it is present and well formed.
 * Requires: query param is in form /?room_id={x}
 * Returns: Some x if well formed, None otherwise)
 *) 

let extract_id req = 
    let uri = Cohttp.Request.uri req in 
    Uri.get_query_param uri "room_id"

(* -------------------------------------------------------- *)
(* Daemons *)

let timeout = Time.Span.of_sec 5.0

let lobby_disconnect ls inactive = 
    let is_active (pn,_) = not (List.mem inactive pn) in 
    let active = List.filter ls.players ~f:is_active in 
    match active with 
        | [] -> failwith "rep not ok"
        | (pn,_)::t -> if List.mem inactive ls.admin 
                        then {admin = pn; players = (pn,true)::t}
                        else {ls with players = active}   

let game_disconnect gs inactive = 
   List.fold ~init:gs ~f:(Game.disconnect_player) inactive

let close_room id = 
    eprintf "Closing Room %s\n" id; 
    Hashtbl.remove rooms id; 
    () 

let heart_beat id now = 
    eprintf "Checking heartbeat... (%s) \n" id; 
    let rd = Hashtbl.find_exn rooms id in 

    let p_disconnect players = 
        let is_healthy (pn,t) = 
            let diff = Time.diff now t in 
            eprintf "\t%s, Difference: %s, Healthy?: %s\n" 
                        (pn) 
                        (Time.Span.to_short_string diff) 
                        (if (diff <= timeout) then "true" else "false");
            diff <= timeout 
        in 

        let collect_activity (active,inactive) (pn,t) =
            if is_healthy (pn,t) then ((pn,t) :: active, inactive) 
                                 else (active, pn :: inactive)
        in 

        List.fold ~init:([],[]) ~f:collect_activity players 
    in

    let (active,inactive) = p_disconnect rd.last_updated in
    eprintf "Active: %n, Inactive: %n\n" (List.length active) (List.length inactive); 

    if active = [] then close_room id (* everyone is gone, close the room *)
    else 
    (* there should at least be one player in the room at this point*)
    
    let state' = match rd.state with 
            | Lobby ls -> Lobby (lobby_disconnect ls inactive)
            | Game gs -> Game (game_disconnect gs inactive) 
    in 

    Hashtbl.set rooms ~key:id ~data:{rd with state = state'; last_updated = active}; 
    ()

let lobby_transition ls now = 
    let players = List.fold ~init:[] ~f:(fun acc (pn,_) -> pn :: acc) ls.players in 
    let gs' = Game.init_state players in
    let t' = Time.add now (Game.time_span gs') in 
    (Game gs', Some t')

let end_game (gs : game_state) = 
    let ply = List.rev (gs.players) in 
    let admin' = match ply with 
                    | [] -> raise (Invalid_argument "room empty")
                    | (pn,_)::t -> pn
    in 

    let grab_players acc (pn,_) = 
        if pn = admin' then (pn,true)::acc
                       else (pn,false)::acc 
    in 

    let players' = List.fold ~init:[] ~f:grab_players ply in 
    (Lobby {admin = admin'; players = players'}, None)

let game_transition rd gs now = 
    if gs.stage = Game_Over then (end_game gs) else 

    (* so... not really. This is close but not the real start time *
      TODO: should we cache the real start time? *)
    let start = Time.sub now (Game.time_span gs) in 

    let collect_updates acc (t,cj) = 
        if t >= start then cj :: acc
                      else acc 
    in 

    (* TODO: verify if these are sorted are not *)
    let updates = List.fold ~init:[] ~f:collect_updates rd.action_buffer in 
    let gs' = Game.step_game gs updates in 
    let t' = Time.add now (Game.time_span gs') in 
    (Game gs', Some t')

let transition rd now = 
    match rd.state with 
        | Lobby ls -> lobby_transition ls now
        | Game gs -> game_transition rd gs now

let transition_beat id now = 
    let rd = Hashtbl.find_exn rooms id in 
    match rd.transition_at with 
        | None -> ()
        | Some t when t > now -> () 
        | Some t -> 
            try 
                let (st',time) = transition rd now in 
                Hashtbl.set rooms ~key:id ~data:{rd with state = st'; transition_at = time};
                ()
            with 
                _ -> close_room id; ()
    
let server_beat _ = 
    let now = Time.now () in 
    eprintf "Server Beat: %s \n" (Time.to_string_fix_proto `Utc now);
    List.iter (Hashtbl.keys rooms) ~f:(fun id -> heart_beat id now); (*check heart_beat*)
    List.iter (Hashtbl.keys rooms) ~f:(fun id -> transition_beat id now);
    ()

let daemon_action conn req body = 
    server_beat ();
    respond `OK "Done."

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
            respond `Bad_request "Malformed room_id."
        | Some s when not (Hashtbl.mem rooms s) -> 
            respond `Bad_request "Room doesn't exist."
        | Some s ->
            let room_data = Hashtbl.find_exn rooms s in op s room_data 

let create_room conn req body = 
    let id = extract_id req in
    match id with 
        | None -> 
            respond`Bad_request "Malformed room_id" 
        | Some s when Hashtbl.mem rooms s -> 
            respond`Bad_request "Room already exists." 
        | Some s -> 
            let room = {
                state = Lobby {admin = ""; players = []};
                transition_at = None; 
                last_updated = []; 
                chat_buffer = [];
                action_buffer = []; 
            } in 
            Hashtbl.set rooms ~key:s ~data:room; 
            eprintf "Room Created! (%s)\n" s; 
            Server.respond_with_string  ~code:`OK "Room created."


let join_room conn req body = 
    let add_player s l =  
        let in_use = List.fold ~init:false ~f:(fun acc (n,_) -> (n = s) || acc) l.players in 
        let too_long = String.length s >= 15 in 

        if (in_use || too_long) then None 
        else if l.players = [] then 
            Some {admin = s; players = [(s,true)]}
        else 
            Some {l with players = (s,false)::l.players}
    in 

    let join body = 
        try 
            let cd = decode_cjson body in 
            let lobby_op id rd = 
                match rd.state with 
                    | Game _ ->
                        respond `Bad_request "Game already in progress."
                    | Lobby l ->
                    let result = add_player (cd.player_id) (l) in 
                    (match result with 
                        | None -> 
                            respond `Bad_request  "player_id in use."
                        | Some l' ->
                            let time = Time.now () in 
                            let room = {rd with  
                                        state = Lobby l';
                                        last_updated = (cd.player_id, time) :: rd.last_updated 
                                       } in 
                            Hashtbl.set rooms ~key:id ~data:room; 
                            eprintf "%s has joined room (%s)\n" cd.player_id id;
                            respond `OK (Time.to_string_fix_proto `Utc (Time.now ())))   
            in 
            room_op (req) (lobby_op)
        with _ -> respond `Bad_request "Malformed client_action.json"

    in 

    Body.to_string body >>= join 
(* -------------------------------------------------------- *)

(* [load_room req cd] returns an action_bundle using the room_id located within
 * the query paramaters of [req]. 
 * Requires: 
 *  - room_id is well formed and registered, Action_Error otherwise *)

let load_room req cd = 
    let id = extract_id req in 
    match id with 
        | None -> 
            raise (Action_Error (respond `Bad_request "Malformed room_id."))
        | Some s when not (Hashtbl.mem rooms s) -> 
            raise (Action_Error (respond `Bad_request "Room doesn't exist."))
        | Some s ->
            let room_data = Hashtbl.find_exn rooms s in {id = s; rd = room_data; cd = cd}

(* [in_room ab] is [ab] if the player specified in the action bundle's client data 
 * is within the room specified in the action bundle's room_data. 
 * Returns Action_Error otherwise. *)

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
        raise (Action_Error (respond `Bad_request (pn ^ " is not in room " ^ id)))

(* [can_chat ab] is [ab] if the player specified in the action bundle's client_data 
 * is able to chat in the supplied room. Returns Action Error otherwise *)

let can_chat ab = 
    let {id; rd; cd} = ab in 
    let pn = cd.player_id in 
    let can_chat = match rd.state with 
                    | Lobby ls -> true 
                    | Game gs -> Game.can_chat gs pn 
    in 

    if can_chat then ab 
    else 
        raise (Action_Error (respond`Bad_request "Cannot Currently Chat"))

(* [write_chat ab] adds the client's chat message into the chat buffer and 
 * returns an 'OK response *)

let write_chat {id; rd; cd} = 
    let pn = cd.player_id in 
    let msg = List.fold ~init:"" ~f:(^) cd.arguments in 
    let addition = ((Time.now ()), pn, msg) in 
    Hashtbl.set rooms ~key:id ~data:{rd with chat_buffer = (addition :: rd.chat_buffer)};
    respond `OK "Done."

(* [write_ready ab] toggles the player's ready state given the client_data and 
 * room_data within the supplied action_bundle. 
 * Requires: the room within [ab] is in lobby mode. *)

let write_ready {id; rd; cd} = 
    let update_players acc (n,s) = 
        if n = cd.player_id then (n,true)::acc 
                            else (n,s)::acc 
    in 
    
    match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Cannot Ready in Game."))
        | Lobby ls ->
            let pl' = List.fold ~init:[] ~f:update_players ls.players in 
            Hashtbl.set rooms ~key:id ~data:{rd with state = Lobby {ls with players = pl'}}; 
            respond `OK "Done."

(* [is_admin ab] is [ab] if the palyer specified within the action_bundle is an 
 * admin in the action_bundle's supplied room, and the room is in lobby mode. 
 * Returns Action_Error otherwise. *)

let is_admin ab = 
    let {id; rd; cd} = ab in
    match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Cannot be Admin in Game"))
        | Lobby ls ->
            if ls.admin = cd.player_id then ab 
            else 
                 raise (Action_Error (respond`Bad_request "Player is not admin."))

(* [all_ready ab] is [ab] if all the players in the room specified by [ab] are 
 * have readied up, and the room is in lobby mode. Returns Action_Error otherwise *)

let all_ready ab =
     let {id; rd; cd} = ab in 

     let check_ready acc (_,ready) = acc && ready in 

     match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Players Already in Game"))
        | Lobby ls -> 
            let ready = List.fold ~init:false ~f:check_ready ls.players in 
            if ready then ab 
            else 
                raise (Action_Error (respond`Bad_request "Not all players are ready."))

(* [write_game ab] moves a game from lobby mode into game mode, and launches the 
 * associated game_state daemons. Requires: Room is in Lobby Mode *)

let write_game ab = 
    let {id; rd; cd} = ab in 
    match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Game already in progress"))
        | Lobby ls ->
           let (st', t') = lobby_transition ls (Time.now ()) in 
           Hashtbl.set rooms ~key:id ~data:{rd with state = st'; transition_at = t'};
           respond `OK "Done."

(* [can_vote ab] is [ab] if the player specified within [ab] can vote in the current 
 * game_state. Returns Action_Error otherwise *)

let can_vote ab = 
    let {id; rd; cd} = ab in 
    match rd.state with 
        | Lobby ls -> raise (Action_Error (respond `Bad_request "Cannot vote in Lobby.")) 
        | Game gs ->
            if Game.can_vote gs id then ab 
            else 
                raise (Action_Error (respond `Bad_request ("Cannot vote during " ^ (string_of_stage gs.stage))))

(* [write_vote ab] adds the vote specified within the client data of the action buffer 
 * to the room's action_queue. Requires that the room is in game mode. *)

let write_vote ab = 
    let {id; rd; cd} = ab in 
    match rd.state with 
        | Lobby _ -> raise (Action_Error (respond `Bad_request "Cannot vote in Lobby"))
        | Game gs ->
            let actbuf' = (Time.now (), cd) :: rd.action_buffer in 
            Hashtbl.set rooms ~key:id ~data:{rd with action_buffer = actbuf'};  
            respond `OK "Done."

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
                | _ -> respond `Bad_request "Invalid Command"
        with 
            | Action_Error response -> response  
            | _ -> respond `Bad_request "Malformed client_action.json"
    in

    Body.to_string body >>= action

(* ------------------------------------------------------------- *)

let extract_days rd = 
    match rd.state with 
        | Lobby ls -> -1 (* no days in lobby *) 
        | Game gs -> gs.day_count 

let extract_stage rd = 
    match rd.state with 
        | Lobby ls -> "Lobby"
        | Game gs -> string_of_stage gs.stage 

let extract_players rd = 
    let l_players acc (pn,_) = pn :: acc in 
    let g_players acc (pn,role) = 
        if role <> Dead then pn :: acc 
                        else acc 
    in 
    
    match rd.state with 
        | Lobby ls -> List.fold ~init: [] ~f: l_players ls.players
        | Game gs -> List.fold ~init: [] ~f: g_players gs.players 

let extract_announce rd last = 
    let g_announce acc (posted,a) = 
        if last > posted then a :: acc
                        else acc 
    in 
    
    match rd.state with 
        | Lobby ls -> [] (* currently there are no announcements in the lobby *)
        | Game gs -> List.fold ~init:[] ~f:g_announce gs.announcement_history

let extract_messages rd last = 
    let messages acc (posted,pn,msg) = 
        if posted > last then (pn,msg)::acc
                        else acc 
    in 
    List.fold ~init:[] ~f: messages rd.chat_buffer 

let refresh_status ab = 
    let {id; rd; cd} = ab in 
    let rec update = function 
        | [] -> [] 
        | (pn,time)::t when pn = cd.player_id -> (pn,Time.now ())::update t
        | h::t -> update t 
    in 
    Hashtbl.set rooms ~key:id ~data:{rd with last_updated = update rd.last_updated}; 
    ab 

let extract_status ab = 
    let {id; rd; cd} = ab in 
    let last = match cd.arguments with 
                | [] -> raise (Action_Error (respond `Bad_request "Must specify initial timestamp"))
                | h::_ -> Time.of_string_fix_proto `Utc h 
    in 
    {
        day_count = extract_days rd;
        game_stage = extract_stage rd; 
        active_players = extract_players rd; 
        new_announcements = extract_announce rd last;
        new_messages = extract_messages rd last;
        timestamp = Time.to_string_fix_proto `Utc (Time.now ());
    }
    
let write_status sj = 
    let response = Data.encode_sjson sj in 
    respond `OK response

let room_status _ req body = 
    let get_status body = 
        try 
            let cd = decode_cjson body in 
            let ab = load_room req cd |> in_room in 
            match cd.player_action with 
                | "get_status" -> ab |> refresh_status |> extract_status |> write_status
                | _ -> respond `Bad_request "Invalid for this endpoint."
        with
            | Action_Error response -> response 
            | _ -> respond `Bad_request "Failure."
    in 

    Body.to_string body >>= get_status
    
(* ------------------------------------------------------------- *)
let handler ~body:body conn req =
    let uri = Cohttp.Request.uri req in 
    let verb = Cohttp.Request.meth req in 
    match Uri.path uri, verb with
        | "/daemon", `POST -> daemon_action conn req body 
        | "/create_room", `POST -> create_room conn req body
        | "/join_room", `POST ->  join_room conn req body 
        | "/player_action", `POST -> player_action conn req body
        | "/room_status", `POST -> room_status conn req body 
        | _ , _ ->
            respond `Not_found "Invalid Route."

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
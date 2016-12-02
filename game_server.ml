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

let reserved_names = ["All";"Innocent";"Mafia";"Player";"Me"]

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

let print_room rd = 
    let cur_state = match rd.state with Game _ -> "Game" | Lobby _ -> "Lobby" in 
    let transition_at = match rd.transition_at with None -> "N/A" | Some t -> Time.to_string_fix_proto `Utc t in
    let last_updated = List.fold ~init:"" 
               ~f: (fun acc (pn,t) -> acc ^ ("(" ^ pn ^ "," ^ (Time.to_string_fix_proto `Utc t) ^ ") ;"))
               rd.last_updated in 
    let messages = List.length rd.chat_buffer in 
    let actions = List.length rd.action_buffer in 
    eprintf "State: %s, Transition At: %s\nPlayer Status: %s\n #msgs: %d, #actions: %d\n" 
        cur_state transition_at last_updated messages actions

(* ----------------------------------------------------- *)
(* - Daemon: *)

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
    eprintf "\nChecking heartbeat... (%s) \n" id; 
    let rd = Hashtbl.find_exn rooms id in 
    print_room rd; 

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
    eprintf ("\t Returning Game to Lobby\n");
    
    let ply = List.rev (gs.players) in 
    let admin' = match ply with 
                    | [] -> raise (Invalid_argument "room empty")
                    | (pn,_)::_ -> pn
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
    eprintf "Game has transitioned to '%s'. Next Transition at: %s"
        (Game.string_of_stage gs'.stage) (t' |> Time.to_string_fix_proto `Utc); 
    (Game gs', Some t')

let transition rd now = 
    match rd.state with 
        | Lobby ls -> lobby_transition ls now
        | Game gs -> game_transition rd gs now

let transition_beat id now = 
    eprintf "\nChecking Transition Rules... (%s)\n" id;
    let rd = Hashtbl.find_exn rooms id in 
    match rd.transition_at with 
        | None ->
            eprintf "\t No Transition Currently Scheduled\n";
            ()
        | Some t when t > now -> 
            eprintf "\tTime To Next Transition: %s\n" (Time.diff t now |> Time.Span.to_short_string);
            ()
        | Some _ -> 
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

let daemon_action _ _ _ = 
    server_beat ();
    respond `OK "Done."

let rec run_daemon () =
  let helper =
    return (server_beat ()) >>= fun _ ->
    after (Core.Std.sec 5.0)
  in
    upon helper (fun _ -> run_daemon ())

(* ----------------------------------------------------- *)
(* - Room Creation: *)

let create_room _ req _ = 
    let id = extract_id req in
    match id with 
        | None -> 
            respond `Bad_request "Malformed room_id" 
        | Some s when Hashtbl.mem rooms s -> 
            respond `Bad_request "Room already exists." 
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

(* ----------------------------------------------------- *)
(* - Room Join: *)

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

let valid_id ab = 
    let player_id = ab.cd.player_id in 
    let players = ab.rd.last_updated in 
    
    let reserved = List.mem reserved_names player_id in 

    let in_use = 
        List.fold ~init:false 
                  ~f:(fun acc (n,_) -> (n = player_id) || acc) 
                  players in 
    
    let too_long = String.length player_id >= 15 in 
    
    if (reserved)
        then raise (Action_Error (respond `Bad_request "Chosen name is a reserved keyword."))
    else if (in_use) 
        then raise (Action_Error (respond `Bad_request "Chosen name in use."))
    else if (too_long) 
        then raise (Action_Error (respond `Bad_request "Chosen name too long."))
    else ab 

let lobby_join ls cd = 
    let id = cd.player_id in 
    if (ls.players = []) then {admin = id; players = [(id,true)]}
    else {ls with players = (id,false)::ls.players}

let write_join ab = 
    let {id; rd; cd} = ab in 
    match rd.state with 
        | Game _ -> 
            raise (Action_Error (respond `Bad_request "Game already in progress."))
        | Lobby ls ->
            let ls' = lobby_join ls cd in 
            let time = Time.now () in 
            let rd' = { rd with 
                            state = Lobby ls'; 
                            last_updated = (cd.player_id, time) :: rd.last_updated;
                      } in 
            Hashtbl.set rooms ~key:id ~data:rd';
            
            eprintf "%s has joined room (%s), Active Players: %d \n" 
                        cd.player_id id (List.length rd'.last_updated);
            
            respond `OK (Time.to_string_fix_proto `Utc time)   

let join_room _ req body = 
    let join body = 
        try 
            let cd = decode_cjson body in 
            let ab = load_room req cd in 
            ab |> valid_id |> write_join
        with 
            | Action_Error response -> response 
            | _ -> respond `Bad_request "Malformed client_action.json"
    in 

    Body.to_string body >>= join 

(* ----------------------------------------------------- *)
(* - Player Action: *)

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
    let rd = ab.rd in 
    let cd = ab.cd in 

    let pn = cd.player_id in 
    let chatty = match rd.state with 
                    | Lobby _ -> true 
                    | Game gs -> Game.can_chat gs pn 
    in 

    if chatty then ab 
    else 
        raise (Action_Error (respond`Bad_request "Cannot Chat in Current Game Mode."))

let in_mafia ab = 
    let rd = ab.rd in 
    let cd = ab.cd in 
    
    let mafioso = match rd.state with 
                    | Lobby _ -> false 
                    | Game gs -> 
                        is_mafia cd.player_id gs
    in 
    
    if mafioso then ab 
    else 
        raise (Action_Error (respond `Bad_request "You are not a member of the mafia!"))

(* [write_chat ab] adds the client's chat message into the chat buffer and 
 * returns an 'OK response *)

let write_chat channel {id; rd; cd} = 
    let pn = cd.player_id in 
    let msg = List.fold ~init:"" ~f:(^) cd.arguments in 
    let addition = ((Time.now ()), (channel, pn, msg)) in 
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
        | Game _ -> raise (Action_Error (respond `Bad_request "Cannot Ready in Game."))
        | Lobby ls ->
            let pl' = List.fold ~init:[] ~f:update_players ls.players in 
            Hashtbl.set rooms ~key:id ~data:{rd with state = Lobby {ls with players = pl'}}; 
            respond `OK "Done."

(* [is_admin ab] is [ab] if the palyer specified within the action_bundle is an 
 * admin in the action_bundle's supplied room, and the room is in lobby mode. 
 * Returns Action_Error otherwise. *)

let is_admin ab = 
    let rd = ab.rd in 
    let cd = ab.cd in 

    match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Cannot be Admin in Game"))
        | Lobby ls ->
            if ls.admin = cd.player_id then ab 
            else 
                 raise (Action_Error (respond`Bad_request "Player is not admin."))

(* [all_ready ab] is [ab] if all the players in the room specified by [ab] are 
 * have readied up, and the room is in lobby mode. Returns Action_Error otherwise *)

let all_ready ab =
     let rd = ab.rd in 

     let check_ready acc (_,ready) = acc && ready in 

     match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Players Already in Game"))
        | Lobby ls -> 
            let ready = List.fold ~init:true ~f:check_ready ls.players in 
            if ready then ab 
            else 
                raise (Action_Error (respond`Bad_request "Not all players are ready."))

(* [write_game ab] moves a game from lobby mode into game mode, and launches the 
 * associated game_state daemons. Requires: Room is in Lobby Mode *)

let write_game ab = 
    let id = ab.id in 
    let rd = ab.rd in 

    match rd.state with 
        | Game _ -> raise (Action_Error (respond`Bad_request "Game already in progress"))
        | Lobby ls ->
           let (st', t') = lobby_transition ls (Time.now ()) in 
           Hashtbl.set rooms ~key:id ~data:{rd with state = st'; transition_at = t'};
           eprintf "(%s) entering Game Mode\n" id; 
           respond `OK "Done."

(* [can_vote ab] is [ab] if the player specified within [ab] can vote in the current 
 * game_state. Returns Action_Error otherwise *)

let can_vote ab = 
    let id = ab.id in 
    let rd = ab.rd in 

    match rd.state with 
        | Lobby _ -> raise (Action_Error (respond `Bad_request "Cannot vote in Lobby.")) 
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
        | Game _ ->
            let actbuf' = (Time.now (), cd) :: rd.action_buffer in 
            Hashtbl.set rooms ~key:id ~data:{rd with action_buffer = actbuf'};  
            respond `OK "Done."

let player_action _ req body = 
    let action body = 
        try 
            let cd = decode_cjson body in
            let ab = load_room req cd |> in_room in  
            eprintf "(%s): Player: %s, Action: %s, Arguments: [%s]\n"
                (ab.id )(cd.player_id) (cd.player_action )
                (List.fold ~init:"" ~f:(fun acc x -> x ^ ";" ^ acc) cd.arguments);
            match cd.player_action with 
                | "chat" -> ab |> can_chat |> write_chat General
                | "mafia-chat" -> ab |> can_chat |> in_mafia |> write_chat Mafia
                | "ready" -> ab |> write_ready  
                | "start" -> ab |> is_admin |> all_ready |> write_game 
                | "vote" -> ab |> can_vote |> write_vote 
                | _ -> respond `Bad_request "Invalid Command"
        with 
            | Action_Error response -> response  
    in

    Body.to_string body >>= action

(* ----------------------------------------------------- *)
(* - Room Status: *)

let extract_days rd = 
    match rd.state with 
        | Lobby _ -> -1 (* no days in lobby *) 
        | Game gs -> gs.day_count 

let extract_stage rd = 
    match rd.state with 
        | Lobby _ -> "Lobby"
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

let extract_announce cd rd last =     
    
    let format_target player_id target = 
     match target with 
        | All -> "All"
        | Innocents -> "Innocent" 
        | Mafias -> "Mafia"
        | Player s when player_id = s -> "Me"
        | Player _ -> failwith "rep_not_ok" 
    in 

    let format_announce (target, msg) = 
        (format_target cd.player_id target ,msg)
    in

    let get_announce gs = 
        fun acc (posted,(target,a)) ->
            let new_msg = last < posted in 
            let intended = can_recieve gs cd.player_id target in 
            if new_msg && intended 
                then (format_announce (target,a)) :: acc
                else acc 
    in 
    
    match rd.state with 
        | Lobby _ -> [] (* currently there are no announcements in the lobby *)
        | Game gs -> List.fold ~init:[] ~f:(get_announce gs) gs.announcement_history

let extract_messages rd cd last = 
    
    let format_message (channel, pn, msg) = 
        let dir = match channel with
                    | General -> "All"
                    | Mafia -> "Mafia"
        in 
        (dir, pn, msg)
    in

    let get_messages acc (posted,(channel,pn,msg)) = 
        let new_msg = last < posted in 
        let intended = 
            match rd.state, channel with 
                | _, General -> true 
                | Game gs, Mafia 
                    when (is_mafia cd.player_id gs) -> true 
                | _, _ -> false 
        in 

        if new_msg && intended 
            then format_message (channel,pn,msg)::acc
            else acc 
    in 

    List.fold ~init:[] ~f: get_messages rd.chat_buffer 

let refresh_status ab = 
    let {id; rd; cd} = ab in 
    let rec update = function 
        | [] -> [] 
        | (pn,_)::t when pn = cd.player_id -> (pn,Time.now ())::update t
        | h::t -> h::update t 
    in 
    Hashtbl.set rooms ~key:id ~data:{rd with last_updated = update rd.last_updated}; 
    ab 

let extract_status ab = 
    let rd = ab.rd in 
    let cd = ab.cd in 

    let last = match cd.arguments with 
                | [] -> raise (Action_Error (respond `Bad_request "Must specify initial timestamp"))
                | h::_ -> Time.of_string_fix_proto `Utc h 
    in 
    {
        day_count = extract_days rd;
        game_stage = extract_stage rd; 
        active_players = extract_players rd; 
        new_announcements = extract_announce cd rd last;
        new_messages = extract_messages rd cd last;
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
            ab |> refresh_status |> extract_status |> write_status
        with
            | Action_Error response -> response 
            | _ -> respond `Bad_request "Failure."
    in 

    Body.to_string body >>= get_status
    
(* ----------------------------------------------------- *)
(* - Server Setup: *)

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
    run_daemon ();
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
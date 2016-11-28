open Data
open Display
open Client_state
open Str
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

(* Case insensitive equals *)
let (+=+) s1 s2 = (String.lowercase s1) = (String.lowercase s2)

(* Add announcements to client_state *)
let add_announcements cs a = cs.announcements <- a @ cs.announcements
  
let make_uri base_url path ?(q_params=[]) () =
  let new_uri = Uri.of_string base_url in
  let new_uri = Uri.with_path new_uri path in
  Uri.add_query_params' new_uri q_params

let send_get uri =
  Client.get uri >>= fun (resp,body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  let new_ivar = Ivar.create () in
  upon (Body.to_string body)
       (fun s -> Ivar.fill new_ivar (code,s));
  Ivar.read new_ivar

let send_post uri ?data () =
  let encoded_data = match data with | None   -> `String ""
                                     | Some d -> `String (encode_cjson d)
  in
  Client.post uri ~body:encoded_data >>= fun (resp,body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  let new_ivar = Ivar.create () in
  upon (Body.to_string body) (fun s -> Ivar.fill new_ivar (code,s));
  Ivar.read new_ivar

(* Main REPL *)
let _ =
  let client_s = { player_id="";
                   room_id="";
                   day_count=0;
                   game_stage="";
                   alive_players=[];
                   dead_players=[];
                   timestamp="";
                   msgs=[];
                   announcements=["Welcome to mafia_of_ocaml!"]; }
  in
  let rec get_input ?(commands=[]) () =
    new_prompt ();
    let input = read_line () in
    let rec found_in s = function
      | [] -> false
      | h::t -> if s +=+ h then true else found_in s t
    in
    if input = "" then get_input ~commands:commands ()
    else if commands = [] then ("",input)
    else
      let first_word,rest = match Str.(bounded_split (regexp " ") input 2) with
                            | h::[]    -> (String.lowercase h,"")
                            | h::t::[] -> (String.lowercase h,t)
                            | _        -> ("","") (* not possible *)
      in
      if found_in first_word commands then (first_word,rest)
      else get_input ~commands:commands ()
  in
  let rec server_verify f =
    f () >>= fun (code,body) ->
    if code = 200 then return (code,body)
    else (print_endline body; server_verify f)
  in
  let server_url = if Array.length Sys.argv < 2
                   then (print_endline "Usage: make client URL=[server URL]";
                         exit 0)
                   else Sys.argv.(1)
  in
  upon (
  init ();
  show_banner ();
  server_verify (fun () ->
    add_announcements client_s ["Type \"join [room_id]\" to join an existing "
                                ^ "room or \"create [room_id]\" to create a "
                                ^ "new room."];
    update_announcements client_s.announcements;
    let cmd,room = get_input ~commands:["join";"create"] () in
    client_s.room_id <- room;
    add_announcements client_s ["Please enter a username that is <= 15 "
                                ^ "characters long."];
    update_announcements client_s.announcements;
    let _,user = get_input () in
    client_s.player_id <- user;
    if cmd = "create"
    then (send_post
         (make_uri server_url "create_room" ~q_params:[("room_id",room)] ()) ()
         >>= fun (code,body) -> 
         if code <> 200
         then (add_announcements client_s [body];
              update_announcements client_s.announcements;
              return (code,body))
         else (send_post
              (make_uri server_url "join_room" ~q_params:[("room_id",room)] ())
              ~data:{player_id=user; player_action="join"; arguments=[]}
              ()))
    else (send_post
         (make_uri server_url "join_room" ~q_params:[("room_id",room)] ())
         ~data:{player_id=user; player_action="join"; arguments=[]}
         ())
  ) >>= fun (_, body) ->
  client_s.timestamp <- body; (* initial timestamp *)
  add_announcements client_s [("Your player ID is " ^ client_s.player_id);
                              ("Joined lobby for room " ^ client_s.room_id);
                             ];
  show_state_and_chat ();
  update_announcements client_s.announcements;
  let user = client_s.player_id in
  let room = client_s.room_id in
  (* update request loop *)
  let rec server_update_loop () =
    let get_update =
      send_post
        (make_uri server_url ("room_status") ~q_params:[("room_id",room)] ())
        ~data:{ player_id=user;
                player_action="get_status";
                arguments=[client_s.timestamp] }
        ()
    in
    upon get_update (fun (code,body) -> 
      (if code = 200 then
        let sj = decode_sjson body in
        update_client_state client_s sj;
        update_announcements client_s.announcements;
        update_chat client_s.msgs;
        (if client_s.game_stage = "GAME_OVER"
        then add_announcements client_s ["Thanks for playing mafia_of_ocaml!"];
             exit 0));
      server_update_loop ()
    )
  in
  (* command loop *)
  let rec user_input_loop () =
    let cmd,args = get_input ~commands:["chat";"ready";"start";"vote"] () in
    send_post
      (make_uri server_url ("player_action") ~q_params:[("room_id",room)] ())
      ~data:{player_id=user; player_action=cmd; arguments=[args]}
      ()
    >>= fun (code,body) ->
    add_announcements client_s [body];
    update_announcements client_s.announcements;
    user_input_loop ()
  in
  server_update_loop ();
  user_input_loop ()

  ) (fun _ -> print_endline "exit"; exit 0)

let _ =
  Scheduler.go ()

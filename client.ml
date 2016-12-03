open Data
open Display
open Client_state
open Str
open Async.Std
open Cohttp
open Cohttp_async

module Fd = Unix.Fd

let help_string =
  "Available commands: ready, start, chat, vote, mafia-chat, help"

(* Add announcements to client_state *)
let add_announcements cs a = cs.announcements <- a @ cs.announcements
  
let make_uri base_url path room =
  let new_uri = Uri.of_string
                (if Str.string_match (Str.regexp "^http://") base_url 0
                 then base_url
                 else "http://" ^ base_url)
  in
  let new_uri = Uri.with_path new_uri path in
  Uri.add_query_params' new_uri [("room_id",room)]

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
  Async_kernel.Monitor.try_with (fun () -> Client.post uri ~body:encoded_data)
  >>= function
  | Core_kernel.Std.Result.Ok (resp,body) ->
      let code = resp |> Response.status |> Code.code_of_status in
      let new_ivar = Ivar.create () in
      upon (Body.to_string body) (fun s -> Ivar.fill new_ivar (code,s));
      Ivar.read new_ivar
  | Core_kernel.Std.Result.Error _ ->
      Pervasives.(print_endline "Server connection error"; exit 0)

(* Start state *)
let client_s = { player_id="";
                 room_id="";
                 day_count=0;
                 game_stage="";
                 alive_players=[];
                 dead_players=[];
                 timestamp="";
                 msgs=[];
                 announcements=[("Me","Welcome to mafia_of_ocaml!")]; }

let rec is_in n = function
  | []   -> false
  | h::t -> if h = n then true else is_in n t

let rec get_input ?(commands=[]) () =
  let input = Pervasives.read_line () in
  new_prompt ();
  let rec found_in s = function
    | [] -> false
    | h::t -> if s = h then true else found_in s t
  in
  if input = "" then get_input ~commands:commands ()
  else if commands = [] then ("",input)
  else
    let first_word,rest = match Str.(bounded_split (regexp " ") input 2) with
                          | h::[]    -> (String.lowercase_ascii h,"")
                          | h::t::[] -> (String.lowercase_ascii h,t)
                          | _        -> ("","") (* not possible *)
    in
    if found_in first_word commands then (first_word,rest)
    else get_input ~commands:commands ()

(*
 * The following code is from the async GitHub repository and has been
 * modified for our use-case.
 * https://github.com/janestreet/async/blob/master/example/cat.ml
 *)
let reader = Reader.create (Fd.stdin())
let writer = Writer.create ~raise_when_consumer_leaves:false (Fd.stdout())
let buf = Core.Std.String.create 4096
let rec get_input_async f =
  choose
    [
      choice (Reader.read reader buf) (fun r -> `Reader r);
      choice (Writer.consumer_left writer) (fun () -> `Epipe);
    ]
  >>> function
  | `Epipe -> shutdown 0
  | `Reader r ->
    match r with
    | `Eof ->
      Writer.flushed writer
      >>> fun _ ->
      shutdown 0
    | `Ok len ->
      let s = Core.Std.Substring.(create buf ~pos:0 ~len |> to_string) in
      redraw_long_string s client_s;
      let s = String.trim s in
      new_prompt ();
      if s = "" then get_input_async f
      else
        let first_word,rest = match Str.(bounded_split (regexp " ") s 2) with
                              | h::[]    -> (String.lowercase_ascii h,"")
                              | h::t::[] -> (String.lowercase_ascii h,t)
                              | _        -> ("","") (* not possible *)
        in
        if is_in first_word ["chat";"ready";"start";"vote";"mafia-chat";"help"]
        then f (first_word,rest)
        else ((match client_s.announcements with
              | (_,h)::_ when h = help_string -> ()
              | _ -> (add_announcements client_s ["Me",help_string];
                      update_announcements client_s.announcements));
             get_input_async f)

let rec server_verify f =
  f () >>= fun (code,body) ->
  if code = 200 then return (code,body)
  else (add_announcements client_s [("Me",body)];
        update_announcements client_s.announcements;
        server_verify f)

(* Main REPL *)
let _ =
  let server_url = if Array.length Sys.argv < 2
                   then Pervasives.(
                        print_endline "Usage: make client URL=[server URL]";
                        exit 0)
                   else Sys.argv.(1)
  in
  init ();
  show_banner ();
  new_prompt ();
  upon (
    server_verify (fun () ->
      add_announcements client_s [("Me","Type \"join [room_id]\" to join an "
                                         ^ "existing room or \"create "
                                         ^ "[room_id]\" to create a new room.")
                                 ];
      update_announcements client_s.announcements;
      let cmd,room = get_input ~commands:["join";"create"] () in
      client_s.room_id <- room;
      add_announcements client_s [("Me","Please enter a username that is <= "
                                         ^ "10 characters long.")];
      update_announcements client_s.announcements;
      let _,user = get_input () in
      client_s.player_id <- user;
      if cmd = "create"
      then (send_post (make_uri server_url "create_room" room) ()
           >>= fun (code,body) -> 
           if code <> 200
           then return (code,body)
           else (send_post
                (make_uri server_url "join_room" room)
                ~data:{player_id=user; player_action="join"; arguments=[]}
                ()))
      else (send_post (make_uri server_url "join_room" room)
                      ~data:{player_id=user; player_action="join"; arguments=[]}
                      ())
    )
  )
  (fun (_, body) ->
    client_s.timestamp <- body; (* initial timestamp *)
    add_announcements client_s [("Me","Your player ID is "
                                       ^ client_s.player_id);
                                ("Me","Joined lobby for room "
                                       ^ client_s.room_id);
                               ];
    show_state_and_chat ();
    add_announcements client_s [("Me",help_string)];
    update_announcements client_s.announcements;
    new_prompt ();
    let user = client_s.player_id in
    let room = client_s.room_id in
    (* update request loop *)
    let rec server_update_loop () =
      let get_update =
        after (Core.Std.sec 0.5) >>= fun _ ->
        send_post (make_uri server_url "room_status" room)
                  ~data:{ player_id=user;
                          player_action="get_status";
                          arguments=[client_s.timestamp] }
                  ()
      in
      upon get_update (fun (code,body) -> 
        (if code = 200 then
          let sj = decode_sjson body in
          let (new_state,new_msgs,new_a) = update_client_state client_s sj in
          if new_state then update_game_state client_s.day_count
                                              client_s.game_stage
                                              client_s.alive_players
                                              client_s.dead_players;
          if new_msgs then update_chat client_s.msgs;
          if new_a then update_announcements client_s.announcements;
        );
        server_update_loop ()
      )
    in
    (* command loop *)
    let rec user_input_loop () =
      get_input_async (fun (cmd,args) ->
        if cmd = "help" then (add_announcements client_s [("Me",help_string)];
                              update_announcements client_s.announcements;
                              user_input_loop ())
        else upon (send_post (make_uri server_url "player_action" room)
                  ~data:{player_id=user; player_action=cmd; arguments=[args]}
                  ())
        (fun (code,body) -> (if code <> 200 then
                            (add_announcements client_s [("Me",body)];
                            update_announcements client_s.announcements);
                            user_input_loop ()))
      )
    in
    server_update_loop ();
    user_input_loop ()
  )

let _ =
  Scheduler.go ()

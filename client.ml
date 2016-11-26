open Data
open Display
open Str
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

(* Case insensitive equals *)
let (+=+) s1 s2 = (String.lowercase s1) = (String.lowercase s2)
  
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

let send_post uri data =
  Client.post uri ~body:(`String (encode_cjson data)) >>= fun (resp,body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  let new_ivar = Ivar.create () in
  upon (Body.to_string body) (fun s -> Ivar.fill new_ivar (code,s));
  Ivar.read new_ivar

(* Main REPL *)
let _ =
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
  let server_url = if Array.length Sys.argv < 2
                   then (print_endline "Usage: make client URL=[server URL]";
                         exit 0)
                   else Sys.argv.(1)
  in
  (*update_announcements*)
  Printf.printf "%s\n" ("Welcome to mafia_of_ocaml! Please enter a username "
                        ^ "that is <= 20 characters long.");
  let _,user = get_input () in
  (*update_announcements*)
  Printf.printf "%s\n" ("Type \"join [room_id]\" to join an existing room or "
                        ^ "\"create [room_id]\" to create a new room.");
  let cmd,room = get_input ~commands:["join";"create"] () in
  let f =
    send_post
          (make_uri server_url (cmd ^ "_room") ~q_params:[("room_id",room)] ())
          {player_id=user; player_action="join"; arguments=[]}
  in
  upon f (fun (code,body) -> print_endline body; print_int code; print_newline ())

let _ =
  Scheduler.go ()

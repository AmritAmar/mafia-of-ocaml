open Data
open Display
open Str
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

let make_uri base_url path query_params =
  let new_uri = Uri.of_string base_url in
  let new_uri = Uri.with_path new_uri path in
  Uri.add_query_params' new_uri query_params

let send_get uri f =
  let code_and_json =
    Client.get uri >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    let new_ivar = Ivar.create () in
    upon (Body.to_string body)
         (fun s -> Ivar.fill new_ivar (code,decode_sjson s));
    Ivar.read new_ivar
  in
  upon code_and_json (fun (code,sjson) -> f code sjson)

let send_post uri data f =
  let code_and_json =
    Client.post uri ~body:(`String (encode_cjson data)) >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    let new_ivar = Ivar.create () in
    upon (Body.to_string body)
         (fun s -> Ivar.fill new_ivar (code,decode_sjson s));
    Ivar.read new_ivar
  in
  upon code_and_json (fun (code,sjson) -> f code sjson)

(* Main REPL *)
let _ =
  let rec get_input ?(commands=[]) () =
    new_prompt ();
    let input = read_line () in
    let rec found_in s = function
      | [] -> false
      | h::t -> if String.lowercase s = String.lowercase h then true
                else found_in s t
    in
    if input = "" then get_input ~commands:commands ()
    else if commands = [] then ("",input)
    else
      let first_word,rest = match Str.(bounded_split (regexp " ") input 2) with
                            | h::[]    -> (h,"")
                            | h::t::[] -> (h,t)
                            | _        -> ("","") (* not possible *)
      in
      if found_in first_word commands then (first_word,rest)
      else get_input ~commands:commands ()
  in
  if Array.length Sys.argv < 2
  then (print_endline "Usage: make client URL=[server URL]"; exit 0);
  (*update_announcements*)
  Printf.printf "%s\n" ("Welcome to mafia_of_ocaml! Please enter a username "
                        ^ "that is <= 20 characters long.");
  let _,user = get_input () in
  (*update_announcements*)
  Printf.printf "%s\n" ("Type \"join [room_id]\" to join an existing room or "
                        ^ "\"create [room_id]\" to create a new room.");
  let cmd,room = get_input ~commands:["join";"create"] () in
  Printf.printf "%s\t%s\t%s\n" user cmd room


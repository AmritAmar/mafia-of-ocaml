open Data
open Display
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
  let rec get_input () =
    new_prompt ();
    let input = read_line () in
    if input = "" then get_input ()
    else input
  in
  if Array.length Sys.argv < 2
  then (print_endline "Usage: make client URL=[server URL]"; exit 0);
  (*update_announcements*)
  Printf.printf "%s\n" ("Welcome to mafia_of_ocaml! Please enter a username "
                        ^ "that is <= 20 characters long.");
  let user = get_input () in
  (*update_announcements*)
  Printf.printf "%s\n" ("Type \"join [room_id]\" to join an existing room or "
                        ^ "\"create [room_id]\" to create a new room.");
  let room = get_input () in
  Printf.printf "%s\t%s\n" user room


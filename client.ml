open Data
open Display
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

type game_state = {
  alive_players: string list;
  dead_players: string list;
  last_msg: string;
}

let send_get url f =
  let code_and_json =
    Client.get (Uri.of_string url) >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    let new_ivar = Ivar.create () in
    upon (Body.to_string body)
         (fun s -> Ivar.fill new_ivar (code,decode_sjson s));
    Ivar.read new_ivar
  in
  upon code_and_json (fun (code,sjson) -> f code sjson)

let send_post url data f =
  let code_and_json =
    Client.post (Uri.of_string url) ~body:(`String (encode_cjson data))
    >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    let new_ivar = Ivar.create () in
    upon (Body.to_string body)
         (fun s -> Ivar.fill new_ivar (code,decode_sjson s));
    Ivar.read new_ivar
  in
  upon code_and_json (fun (code,sjson) -> f code sjson)

(* Main REPL *)
let _ =
  let rec reprompt f err_msg =
    new_prompt ();
    let input = read_line () in
    if f input then input
    else (update_announcements [err_msg]; reprompt f err_msg)
  in
  update_announcements ["Welcome to mafia_of_ocaml! Please enter a username.";
                        "The username should be <= 20 characters long."];
  reprompt (fun s -> String.length s <= 20)
           "Please enter a username that is <= 20 characters long."

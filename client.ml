open Data
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
  let rec get_resp () =
    Client.get (Uri.of_string url) >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    if code <> 200 then get_resp ()
    else Body.to_string body
  in
  upon (get_resp ()) (fun s -> s |> decode_sjson |> f)

let send_post url data f =
  let rec get_resp () =
    Client.post (Uri.of_string url) ~body:(`String (encode_cjson data))
    >>= fun (resp,body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    if code <> 200 then get_resp ()
    else Body.to_string body
  in
  upon (get_resp ()) (fun s -> s |> decode_sjson |> f)


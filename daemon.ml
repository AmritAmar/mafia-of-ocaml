open Core.Std 
open Async.Std

open Cohttp
open Cohttp_async

let url = "localhost:3110/daemon"

let rec loop () =
  let helper =
    Client.post (Uri.of_string url) >>= fun _ ->
    after (Core.Std.sec 5.0)
  in
    upon helper (fun _ -> loop ())

let _ =
  loop ();
  Scheduler.go ()

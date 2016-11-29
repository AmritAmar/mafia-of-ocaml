open Core.Std 
open Async.Std

open Cohttp
open Cohttp_async

let url = "http://localhost:3110/daemon"

let rec loop () =
  let helper =
    Cohttp_async.Client.post (Uri.of_string url) >>= fun _ ->
    after (Core.Std.sec 5.0)
  in
    upon helper (fun _ -> loop ())

let _ =
  loop ();
  Scheduler.go ()

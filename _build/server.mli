open Lwt
open Cohttp
open Cohttp_lwt_unix

	
(**
 * A simple cohttp server that outputs back request information.
 *)
val server : conn -> Cohttp.Request.t -> Cohttp_lwt_body.t -> (Cohttp.Response.t * Cohttp_lwt_body.t) Lwt.t
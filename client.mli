open Data
open Display
open Client_state
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

(**
 * [make_uri base_url path room] will turn the given base_url, path,
 * and room into a Uri.t instance. The room will be set as the value of
 * the "room_id" query parameter.
 *)
val make_uri : string -> string -> string -> Uri.t

(**
 * [send_post url data] will convert [data] into a JSON string and send it to
 * the URL specified by [url] as a POST request. A deferred is returned that
 * will be determined with the resulting status code and body string when the
 * client receives a response from the server.
 *)
val send_post : Uri.t -> ?data:client_json -> unit -> (int * string) Deferred.t

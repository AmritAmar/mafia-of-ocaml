open Data
open Display
open Client_state
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

(**
 * [make_uri base_url path q_params ()] will turn the given base_url, path,
 * and query parameters into a Uri.t instance. The query parameters are
 * optional.
 *)
val make_uri : string -> string -> string -> Uri.t

(**
 * [send_get url f] will send a GET request to the URL specified by [url], parse
 * the resulting JSON into a server_json record, and pass it, along with the
 * status code into [f].
 *)
val send_get : Uri.t -> (int * string) Deferred.t

(**
 * [send_post url data f] will convert [data] into a JSON string and send it to
 * the URL specified by [url] as a POST request. The resulting JSON will be
 * parsed into a server_json record and passed, along with the status code,
 * into [f].
 *)
val send_post : Uri.t -> ?data:client_json -> unit -> (int * string) Deferred.t

open Data
open Display
open Async.Std
open Core.Std
open Cohttp
open Cohttp_async

(**
 * [make_uri base_url path query_params] will turn the given base_url, path,
 * and query parameters into a Uri.t instance.
 *)
val make_uri : string -> string -> ?q_params:(string * string) list -> unit -> Uri.t

(**
 * [send_get url f] will send a GET request to the URL specified by [url], parse
 * the resulting JSON into a server_json record, and pass it, along with the
 * status code into [f].
 *)
val send_get : Uri.t -> (int -> server_json -> unit) -> unit

(**
 * [send_post url data f] will convert [data] into a JSON string and send it to
 * the URL specified by [url] as a POST request. The resulting JSON will be
 * parsed into a server_json record and passed, along with the status code,
 * into [f].
 *)
val send_post : Uri.t -> client_json -> (int -> server_json -> unit) -> unit

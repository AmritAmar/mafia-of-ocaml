open Yojson.Basic.Util

type data = {
  (* TODO *)
}

(**
 * [get url f] will send a get request to the URL specified by [url], parse the
 * resulting JSON into a data record, and pass the data into [f]. If the get
 * request results in an error, an exception will be raised.
 *)
val get : string -> ( data -> unit ) -> unit


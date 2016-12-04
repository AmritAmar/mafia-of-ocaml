open Data

module Str_set : sig
  type elt = String.t
  type t = Set.Make(String).t
  val empty : t
  val is_empty : t -> bool
  val mem : elt -> t -> bool
  val add : elt -> t -> t
  val singleton : elt -> t
  val remove : elt -> t -> t
  val union : t -> t -> t
  val inter : t -> t -> t
  val diff : t -> t -> t
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val subset : t -> t -> bool
  val iter : (elt -> unit) -> t -> unit
  val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
  val for_all : (elt -> bool) -> t -> bool
  val exists : (elt -> bool) -> t -> bool
  val filter : (elt -> bool) -> t -> t
  val partition : (elt -> bool) -> t -> t * t
  val cardinal : t -> int
  val elements : t -> elt list
  val min_elt : t -> elt
  val max_elt : t -> elt
  val choose : t -> elt
  val split : elt -> t -> t * bool * t
  val find : elt -> t -> elt
  val of_list : elt list -> t
end

type client_state = {
  mutable player_id: string;
  mutable room_id: string;
  mutable day_count: int;
  mutable game_stage: string;
  mutable alive_players: Str_set.t;
  mutable dead_players: string list;
  mutable timestamp: string;
  mutable msgs: (string * string * string) list;
  mutable announcements: (string * string) list;
}

(**
 * [update_players cs active] will update [cs] with the given Str_set of
 * active players.
 *)
val update_players : client_state -> Str_set.t -> unit

(**
 * [update_client_state cs sj] will update [cs] with the info in the given
 * server_json record and return a tuple [(new_gs,new_msgs,new_a)], where
 * [new_gs] is whether day_count, game_stage, alive_players, or dead_players
 * has been updated, [new_msgs] is whether msgs has been updated, and [new_a]
 * is whether announcements has been updated.
 *)
val update_client_state : client_state -> server_json -> (bool * bool * bool)

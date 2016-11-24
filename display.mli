(**
 * Updates the chat log with the given list of strings. The list will be
 * ordered by how recent the message is (most recent to least recent).
 *)
val update_chat : string list -> unit

(**
 * Updates the display of the game state with the given game_state record.
 *)
val update_game_state : game_state -> unit

(**
 * Updates the announcements displayed, replaying the old announcements with
 * the given list of strings.
 *)
val update_announcements : string list -> unit


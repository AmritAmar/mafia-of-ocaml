open Client

(**
 * Updates the chat log with the given list of strings. The list will be
 * ordered by how recent the message is (most recent to least recent). Returns
 * the cursor to its position before this function was called.
 *)
val update_chat : string list -> unit

(**
 * Updates the display of the game state with the given game_state record.
 * Returns the cursor to its position before this function was called.
 *)
val update_game_state : game_state -> unit

(**
 * Updates the announcements displayed, replacing the old announcements with
 * the given list of strings. Returns the cursor to its position before this
 * function was called.
 *)
val update_announcements : string list -> unit

(**
 * Prints prompt characters at the beginning of the last line (e.g. "> ") and
 * leaves the cursor in the position directly after them.
 *)
val new_prompt : unit -> unit

(**
 * Prints a welcome banner using ASCII art to be displayed in the space where
 * the game_state and chat will later show up. Displayed whenever user is not
 * in a game room. Returns the cursor to its position before this function was
 * called.
 *)
val show_banner : unit -> unit

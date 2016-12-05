open Client_state

(**
 * Updates the chat log with the given list of string tuples. The list will be
 * ordered by how recent the message is (most recent to least recent). Returns
 * the cursor to its position before this function was called.
 *)
val update_chat : (string * string * string) list -> unit

(**
 * [update_game_state cs] will update the display of the game state with the
 * info in the given client_state record. Returns the cursor to its
 * position before this function was called.
 *)
val update_game_state : client_state -> unit

(**
 * Updates the announcements displayed, replacing the old announcements with
 * the given list of string tuples. Returns the cursor to its position before
 * this function was called.
 *)
val update_announcements : (string * string) list -> unit

(**
 * Prints prompt characters at the beginning of the last line (e.g. "> ") and
 * leaves the cursor in the position directly after them.
 *)
val new_prompt : unit -> unit

(**
 * Prints a welcome banner using ASCII art to be displayed in the space where
 * the client_state and chat will later show up. Displayed whenever user is not
 * in a game room. Returns the cursor to its position before this function was
 * called.
 *)
val show_banner : unit -> unit

(**
 * If the user input is longer than one line, erase the screen and redraw
 * everything
 *)
val redraw_long_string : string -> client_state-> unit

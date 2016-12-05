open ANSITerminal
open Client_state

let scroll = [
"                                               .---.";
"                                              /  .  \\";
"                                             |\\_/|   |";
"                                             |   |  /|";
"  .------------------------------------------------' |";
" /  .-.                                              |";
"|  /   \\                                             |";
"| |\\_.  |                                            |";
"|\\|  | /|                                            |";
"| `---' |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            |";
"|       |                                            /";
"|       |-------------------------------------------'";
"\\       |";
" \\     /";
"  `---'"]

let title = [
" __  __        __ _                __ ";
"|  \\/  |      / _(_)              / _|";
"| \\  / | __ _| |_ _  __ _    ___ | |_ ";
"| |\\/| |/ _` |  _| |/ _` |  / _ \\|  _|";
"| |  | | (_| | | | | (_| | | (_) | |  ";
"|_|  |_|\\__,_|_| |_|\\__,_|  \\___/|_|  ";
"                                      ";
"                                      ";
"  ____   _____                _ ";
" / __ \\ / ____|              | |";
"| |  | | |     __ _ _ __ ___ | |";
"| |  | | |    / _` | '_ ` _ \\| |";
"| |__| | |___| (_| | | | | | | |";
" \\____/ \\_____\\__,_|_| |_| |_|_|"]

let authors = [
" _ ";
"| |";
"|/_            Michael    Irene";
"|/ \\_|  | ";
" \\_/ \\_/|/     Tyler      Rachel";
"       /| ";
"       \\| ";]

let game_state = [
"  ______________________________________________________";
" / \\                                                    \\";
" |  |                                                   |";
"  \\_|                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |                                                   |";
"    |  _________________________________________________|__";
"    \\_/___________________________________________________/"]

let chat_log = [
" _______________________________________________________";
"|  ___________________________________________________  |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |                                                   | |";
"| |___________________________________________________| |";
"|_______________________________________________________|"]

let brick_wall = [
" ___________________________________";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|";
"|_|___|___|___|___|___|___|___|___|_|";
"|___|___|___|___|___|___|___|___|___|"]

let paper = [
" _____________________________";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|                             |";
"|_____________________________|"]


let screen_width = 100

let screen_height = 41

(* [explode s] converts a string to a character list
 * source: https://caml.inria.fr/pub/old_caml_site/Examples/oc/basics/explode.ml
 *)
let explode s =
  let rec expl i l =
    if i < 0 then l else
    expl (i - 1) (s.[i] :: l) in
  expl (String.length s - 1) []

(* [split_word n str prevacc] splits a long word into a list of strings of size
 * n. If there is a previous accumulator, it accounts for that into the total
 * length.
 *)
let split_word n str prevacc =
  let charlist = explode str in
  let rec helper i lst s acc =
  match lst with
    | [] -> acc@[s]
    | h::t when i=0 -> helper n t "" (acc@[s])
    | h::t -> helper (i-1) t (s^(Char.escaped h)) acc
  in
  if prevacc = "" then
    helper n charlist "" []
  else
    helper (n-String.length prevacc-1) charlist (prevacc^" ") []


(* [split_string n str] inputs a string [str] and splits it into a list of
 * strings that are at most [n] characters long where n > 0.
 * precondition: n > 0
 *)
let split_string n str =
  let word_list =
    match Str.split (Str.regexp "[ \t\n]+") str with
    | [] -> []
    | h::t -> if String.length h > n then (split_word n h "")@t
              else h::t in

  let w =
    match word_list with
    | [] -> []
    | h::t -> t in

  let acc =
    match word_list with
    | [] -> ""
    | h::t -> h in

  let rec helper w acc l =
    match w with
    | [] -> l@[acc]
    | h::t -> if String.length h > n then helper ((split_word n h acc)@t) "" l
              else if (String.length h) + (String.length acc) >= n && acc <> ""
                then helper t h (l@[acc])
              else if (String.length h) + (String.length acc) >= n && acc = ""
                then helper t h l
              else helper t (acc^" "^h) l
  in helper w acc []

(* [print_object x y style endline arr] prints a list of strings [arr] at coord
 * [x],[y] in the style of [style]. If it reaches [endline] it stops printing.
 *)
let rec print_object x y style endline arr =
  match arr with
  | [] -> ()
  | h::t -> if y<endline then (set_cursor x y;
                           print_string style h;
                           print_object x (y+1) style endline t)
            else ()


(* [print_list x y style endline n lst skip] takes in a list of strings, breaks
 * each string into a list of strings of a certain length, and prints them with
 * at coordinates [x],[y] with style [style] and [skip] number of breaks. If it
 * reaches [endline] it stops printing.
 *)
let rec print_list x y style endline n lst skip =
  match lst with
  | [] -> ()
  | h::t -> let len = List.length (split_string n h) in
            print_object x y style endline (split_string n h);
            print_list x (y+len+skip) style endline n t skip


(* [erase_box x y width height] erases everything on the screen at coordinates
 * [x],[y] spanning [width] and [height].
 *)
let erase_box x y width height =
  let spaces = String.make width ' ' in
  let lst = let rec fill h =
              match h with
              | 0 -> []
              | n -> spaces::(fill (n-1))
            in fill height in
  print_object x y [] screen_height lst;
  ()

(* [print_message x y style endline arr] takes in a list of chat message strings
 * and breaks each of them into a list of strings of a certain length. It then
 * prints the strings from down to up starting at coordinates [x],[y] with
 * style [style].
 *)
let rec print_message x y style endline arr =
  match arr with
  | [] -> ()
  | h::t -> if y>endline then (set_cursor x y;
                           print_string style h;
                           print_message x (y-1) style endline t)
            else ()

let afst (x,_,_) = x

let asnd (_,y,_) = y

let athrd (_,_,z) = z

(* [print_chat x y style1 style2 endline n1 n2 lst] prints chat messages at
 * coordinates [x],[y] with usernames in [style1] and messages in [style2].
 *)
let rec print_chat x y style1 style2 endline n1 n2 lst =
  match lst with
  | [] -> ()
  | h::t -> let style3 = if String.uppercase_ascii (afst h) = "ALL" then style2
                         else [red] in
            let user = split_string n1 (asnd h) in
            let chat = split_string n2 (athrd h) in
            let len = max (List.length user) (List.length chat) in
    (print_message x (y-len+(List.length user)) style1 endline (List.rev user);
    print_message (x+n1+2) y style3 endline (List.rev chat);
    print_chat x (y-len-1) style1 style2 endline n1 n2 t)

(* [print_a x y endline n lst skip] prints announcements at coordinates [x],[y]
 * in different colors depending on whether its for everyone, innocents, mafia,
 * or just the player.
 *)
let rec print_a x y endline n lst skip =
  match lst with
  | [] -> ()
  | h::t -> let len = List.length (split_string n (snd h)) in
            if String.uppercase_ascii (fst h) = "ALL" then
              (print_object x y [white] endline (split_string n (snd h));
              print_a x (y+len+skip) endline n t skip)

            else if String.uppercase_ascii (fst h) = "INNOCENT" then
              (print_object x y [green] endline (split_string n (snd h));
              print_a x (y+len+skip) endline n t skip)

            else if String.uppercase_ascii (fst h) = "MAFIA" then
              (print_object x y [red] endline (split_string n (snd h));
              print_a x (y+len+skip) endline n t skip)

            else if String.uppercase_ascii (fst h) = "ME" then
              (print_object x y [cyan] endline (split_string n (snd h));
              print_a x (y+len+skip) endline n t skip)

let update_announcements a =
  save_cursor();
  erase_box 68 8 25 27;
  print_a 68 8 35 25 a 2;
  restore_cursor();
  ()

let update_chat log =
  save_cursor();
  erase_box 8 17 47 20;
  print_chat 8 36 [yellow] [cyan] 16 10 35 log;
  restore_cursor();
  ()

(* [scheme day game_stage wall p scroll log chat] changes the color scheme of
 * the page given [wall], [p], [scroll], [log], and [chat]
 *)
let scheme day game_stage wall p scroll log chat =
  print_object 62 1 wall screen_height brick_wall;
  print_object 65 4 p screen_height paper;
  print_object 1 1 scroll screen_height game_state;
  print_object 3 14 log screen_height chat_log;
  print_object 73 6 [Bold;black;on_white] screen_height [" ANNOUNCEMENTS "];
  print_object 40 15 ([Bold;white]@chat) screen_height [" CHAT LOG "];
  if String.uppercase_ascii game_stage = "LOBBY" then
    (erase_box 23 3 30 1;
    print_object 23 3 ([Bold]@scroll) screen_height ["CONNECTED"];
    print_object 8 5 scroll screen_height ["You are now";"in the"];
    print_object 8 7 [magenta;Bold] 12 [game_stage])
  else if String.uppercase_ascii game_stage = "GAME OVER" then
    print_object 8 5 [magenta;Bold] 12 [game_stage]
  else
    (erase_box 23 3 30 1;
    print_object 8 5 scroll screen_height ["It is"];
    print_object 8 7 scroll screen_height ["time"];
    print_object 8 6 [magenta;Bold] 12 [game_stage]);

  if String.uppercase_ascii game_stage <> "LOBBY" then
    (print_object 8 3 ([Bold]@scroll) screen_height ["DAY"];
    print_object 12 3 [blue;Bold] 12 [string_of_int day];
    print_object 23 3 ([Bold]@scroll) screen_height ["ALIVE"];
    print_object 40 3 ([Bold]@scroll) screen_height ["DEAD"]);
  ()

let update_game_state cs =
  let day = cs.day_count in
  let game_stage = cs.game_stage in
  let alive = Str_set.elements cs.alive_players in
  let dead = cs.dead_players in
  save_cursor();
  erase_box 12 3 4 1;
  erase_box 8 5 11 3;
  erase_box 21 5 33 7;
  if String.uppercase_ascii game_stage = "LOBBY" then
    scheme day game_stage [magenta] [] [yellow] [blue] [on_blue]
  else if String.uppercase_ascii game_stage = "GAME OVER" then
    scheme day game_stage [blue] [] [white] [magenta] [on_magenta]
  else if String.uppercase_ascii game_stage = "DISCUSSION" then
    scheme day game_stage [yellow] [magenta] [cyan] [green] [on_green]
  else if String.uppercase_ascii game_stage = "VOTING" then
    scheme day game_stage [green] [blue] [blue] [yellow] [on_yellow]
  else if String.uppercase_ascii game_stage = "NIGHT" then
    scheme day game_stage [white] [] [magenta] [cyan] [on_cyan];

  if String.uppercase_ascii game_stage <> "LOBBY" then
    print_list 40 5 [red] 12 20 dead 0;

  print_list 23 5 [green] 12 20 alive 0;
  restore_cursor();
  update_announcements cs.announcements;
  update_chat cs.msgs;
  ()


let init () =
  resize screen_width screen_height;
  erase Screen;
  print_object 62 1 [magenta] screen_height brick_wall;
  print_object 65 4 [] screen_height paper;
  print_object 73 6 [Bold;black;on_white] screen_height [" ANNOUNCEMENTS "];
  ()

let show_banner () =
  init ();
  print_object 4 2 [yellow] screen_height scroll;
  print_object 16 10 [red] screen_height title;
  print_object 16 25 [green] screen_height authors;
  ()

let prompt = "> "

let new_prompt () =
  set_cursor 2 (screen_height-1);
  erase Eol;
  print_string [] prompt;
  flush_all ()

let redraw_long_string s state =
  let lines = String.(length s + length prompt - 1) / screen_width in
  if lines > 0
  then (erase Screen;
       init ();
       update_game_state state;
       update_announcements state.announcements;
       set_cursor 1 screen_height;
       erase Eol)



(* let () =
  show_banner ();
  scheme 5 "Lobby" [magenta] [] [yellow] [blue] [on_blue];

  scheme 4 "Game Over" [blue] [] [white] [magenta] [on_magenta];
  scheme 3 "Discussion" [yellow] [magenta] [cyan] [green] [on_green];
  scheme 2 "Voting" [green] [blue] [blue] [yellow] [on_yellow];
  scheme 5 "Night" [white] [] [magenta] [cyan] [on_cyan];

  new_prompt (); *)



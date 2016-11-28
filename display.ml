open ANSITerminal

let dead = [ "Tyler"; "Irene"; "Michael"; "Rachel" ]

let alive = [ "Clarkson" ; "Myers" ]

let test_a = ["hello this is a very long announcement that
  I really had to announce"; "this is another very long
  announcement just for testing"(* ; "this is another very long
  announcement just for testing"; "this is another very long
  announcement just for testing"; "this is another very long
  announcement just for testing this is another very long
  announcement just for testing this is another very long
  announcement just for testing this is another very long
  announcement just for testing" *)]

let test_c = [("Clarkson","this is a really cool game");
("Myers","I agree with Clarkson that this is a cool game")]

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
"  ____________________________________________________";
" / \\                                                  \\";
" |  |                                                 |";
"  \\_|                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |                                                 |";
"    |  _______________________________________________|__";
"    \\_/_________________________________________________/"]

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


let width = 100

let height = 41




(* let s2 x y style n str =
  set_cursor x y;
  let words = Str.split (Str.regexp "[ \t]+") str in
  let word_list =
    match words with
    | [] -> []
    | h::t -> t in
  let accumulator =
    match words with
    | [] -> ""
    | h::t -> h in
  let rec helper w acc x y =
    match w with
    | [] -> set_cursor x y; print_string style acc
    | h::t -> if (String.length h) + (String.length acc) >= n
                then (set_cursor x y; print_string style (acc^"\n"); helper t h x (y+1))
              else helper t (acc^" "^h) x y
  in helper word_list accumulator x y *)

(* [split_string n str] inputs a string [str] and splits it into a list of
 * strings that are at most [n] characters long
*)
let split_string n str =
  let word_list = Str.split (Str.regexp "[ \t\n]+") str in

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
    | h::t -> (* if String.length h >=n && h<>acc then
      let front = (String.sub h 0 (n-String.length acc-1)) in
      let back = (String.sub h (n-String.length acc-1) (String.length h-2)) in
      helper (back::t) back (l@[acc^front])
              else if String.length h >=n && h=acc then
      let front = (String.sub h 0 (n-String.length acc-1)) in
      let back = (String.sub h (n-String.length acc-1) (String.length h-2)) in
      helper (back::t) back (l@[acc^front])
              else  *)if (String.length h) + (String.length acc) >= n
                then helper t h (l@[acc])
              else helper t (acc^" "^h) l
  in helper w acc []

(* [print_object x y style arr] prints a list of strings [arr] at coordinates
 * [x],[y] in the style of [style]
*)
let rec print_object x y style arr =
  match arr with
  | [] -> ()
  | h::t -> set_cursor x y;
            print_string style h;
            print_object x (y+1) style t

(* [print_list x y style n lst skip] takes in a list of strings, breaks each
 * string into a list of strings of a certain length, and prints them with at
 * coordinates [x],[y] with style [style] and [skip] number of breaks.
*)
let rec print_list x y style n lst skip =
  match lst with
  | [] -> ()
  | h::t -> let len = List.length (split_string n h) in
            print_object x y style (split_string n h);
            print_list x (y+len+skip) style n t skip

let erase_box x y width height =
  let spaces = String.make width ' ' in
  let lst = let rec fill h =
              match h with
              | 0 -> []
              | n -> spaces::(fill (n-1))
            in fill height in
  print_object x y [] lst;
  ()

let update_announcements a =
  save_cursor();
  erase_box 68 8 25 27;
  print_list 68 8 [cyan] 25 a 2;
  restore_cursor();
  ()

let rec fst_lst lst =
  match lst with
  | [] -> []
  | h::t -> (fst h)::(fst_lst t)

let rec snd_lst lst =
  match lst with
  | [] -> []
  | h::t -> (snd h)::(snd_lst t)

let update_chat log =
  save_cursor();
  erase_box 8 17 47 20;
  print_list 8 17 [cyan] 15 (fst_lst log) 1;
  print_list 17 17 [yellow] 40 (snd_lst log) 1;
  restore_cursor();
  ()

let update_game_state day game_stage alive dead =
  save_cursor();
  erase_box 12 3 4 1;
  erase_box 8 5 46 7;
  print_object 12 3 [blue] [string_of_int day];
  print_object 8 5 [magenta] [game_stage];
  print_list 21 5 [green] 20 alive 0;
  print_list 38 5 [red] 20 dead 0;
  restore_cursor();
  ()

let init =
  resize width height;
  erase Screen;
  print_object 62 1 [magenta] brick_wall;
  print_object 65 4 [] paper;
  print_object 73 6 [Bold;black;on_white] [" ANNOUNCEMENTS "];
  ()

let show_banner () =
  init;
  print_object 4 2 [yellow] scroll;
  print_object 16 10 [red] title;
  print_object 16 25 [green] authors;
  ()

let show_state_and_chat () =
  init;
  print_object 1 1 [yellow] game_state;
  print_object 3 14 [blue] chat_log;
  print_object 8 3 [Bold;yellow] ["DAY"];
  print_object 21 3 [Bold;yellow] ["ALIVE"];
  print_object 38 3 [Bold;yellow] ["DEAD"];
  print_object 40 15 [Bold;white;on_blue] [" CHAT LOG "];
  ()


let new_prompt () =
  set_cursor 2 (height-1);
  erase Eol;
  print_string [] "> ";
  let _ = read_line() in
  ()

let () =
  (* show_banner (); *)
  show_state_and_chat();
  update_announcements test_a;
  update_chat test_c;
  update_game_state 20 "Morning" alive dead;
  new_prompt ();


open ANSITerminal

let dead = [ "Tyler"; "Irene"; "Michael"; "Rachel" ]

let alive = [ "Clarkson" ; "Myers" ]

let test_a = ["example announcement"; "hello this is a very long announcement that
  I really had to announce"; "this is another very long
  announcement just for testing"; "this is another very long
  announcement just for testing"; "this is another very long
  announcement just for testing"; "this is another very long
  announcement just for testing this is another very long
  announcement just for testing this is another very long
  announcement just for testing this is another very long
  announcement just for testing"]

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


let screen_width = 100

let screen_height = 41

(* let split_word w n acc =
  match w, n, acc with
  | "",0,"" -> failwith "Invalid"
  | "",0,s -> failwith "Invalid"
  | s,0,"" -> failwith "Invalid"
  | s1,0,s2 -> failwith "Invalid"
  | "",n,"" -> failwith "Invalid"
  | "",n,s -> failwith "Invalid"
  | s, n, "" -> (String.sub s 0 (n-1),String.sub s (n-1) (String.length s-2))
  | s1, n, s2 -> (String.sub s1 0 (n-(String.length s2)-1),String.sub s1 (n-(String.length s2)-1) (String.length s1-2))
 *)
(* [split_string n str] inputs a string [str] and splits it into a list of
 * strings that are at most [n] characters long where n > 0.
 * precondition: n > 0
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
    | h::t -> (* if String.length h >=n then
      let split = split_word h n acc in
      helper ((snd split)::t) "" (l@[acc^" "^(fst split)])
              else  *)if (String.length h) + (String.length acc) >= n
                then helper t h (l@[acc])
              else helper t (acc^" "^h) l
  in helper w acc []

(* [print_object x y style endline arr] prints a list of strings [arr] at coord
 * [x],[y] in the style of [style]. If it reaches [endline] it stops printing.
*)
let rec print_object x y style endline arr =
  match arr with
  | [] -> ()
  | h::t -> if y<>endline then (set_cursor x y;
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

let update_announcements a =
  save_cursor();
  erase_box 68 8 25 27;
  print_list 68 8 [cyan] 35 25 a 2;
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
  print_list 8 17 [cyan] 37 15 (fst_lst log) 1;
  print_list 17 17 [yellow] 37 40 (snd_lst log) 1;
  restore_cursor();
  ()

let update_game_state day game_stage alive dead =
  save_cursor();
  erase_box 12 3 4 1;
  erase_box 8 5 46 7;
  print_object 12 3 [blue] 12 [string_of_int day];
  print_object 8 5 [magenta] 12 [game_stage];
  print_list 21 5 [green] 12 20 alive 0;
  print_list 38 5 [red] 12 20 dead 0;
  restore_cursor();
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

let show_state_and_chat () =
  init ();
  print_object 1 1 [yellow] screen_height game_state;
  print_object 3 14 [blue] screen_height chat_log;
  print_object 8 3 [Bold;yellow] screen_height ["DAY"];
  print_object 21 3 [Bold;yellow] screen_height ["ALIVE"];
  print_object 38 3 [Bold;yellow] screen_height ["DEAD"];
  print_object 40 15 [Bold;white;on_blue] screen_height [" CHAT LOG "];
  ()


let new_prompt () =
  set_cursor 2 (screen_height-1);
  erase Eol;
  print_string [] "> "

(*
let () =
  (* show_banner (); *)
  show_state_and_chat();
  update_announcements test_a;
  update_chat test_c;
  update_game_state 20 "Morning" alive dead;
  new_prompt ();
*)

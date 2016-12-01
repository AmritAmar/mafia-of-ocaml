open ANSITerminal

let dead = [ "Tyler"; "Irene"; "Michael"; "Rachel" ]

let alive = [ "Clarkson" ; "Myers" ]

let test_a = [("ALL","example announcement");
("MAFIA","example announcement for only mafia");
("ME","this is an announcement that only I can see")]

let test_c = [("All", "Myers","I think you are the mafia");
("Mafia","Clarkson","I don't think I am the mafia")]

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
    | h::t -> if (String.length h) + (String.length acc) >= n
                then helper t h (l@[acc])
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

let rec print_chat x y style1 style2 endline n1 n2 lst =
  match lst with
  | [] -> ()
  | h::t -> let style3 = if String.uppercase_ascii (afst h) = "ALL" then style2
                         else [red] in
            let user = split_string n1 (asnd h) in
            let chat = split_string n2 (athrd h) in
            let len = max (List.length user) (List.length chat) in
  if (List.length user) > (List.length chat) then
    (print_message x y style1 endline (List.rev user);
    print_message (x+n1+1) (y-len+(List.length chat)) style3 endline (List.rev chat);
    print_chat x (y-len-1) style1 style2 endline n1 n2 t)
  else
    (print_message x (y-len+(List.length user)) style1 endline (List.rev user);
    print_message (x+n1+1) y style3 endline (List.rev chat);
    print_chat x (y-len-1) style1 style2 endline n1 n2 t)


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
  print_chat 8 36 [yellow] [cyan] 16 10 36 log;
  restore_cursor();
  ()

let update_game_state day game_stage alive dead =
  save_cursor();
  erase_box 12 3 4 1;
  erase_box 8 6 11 1;
  erase_box 21 5 33 7;
  if day >= 0 then print_object 12 3 [blue;Bold] 12 [string_of_int day];
  if String.uppercase_ascii game_stage = "LOBBY" then
    (print_object 8 5 [yellow] screen_height ["You are now";"in the"];
    print_object 8 7 [magenta;Bold] 12 [game_stage])
  else
    (print_object 8 5 [yellow] screen_height ["It is"];
    print_object 8 7 [yellow] screen_height ["time"];
    print_object 8 6 [magenta;Bold] 12 [game_stage]);
  print_list 23 5 [green] 12 20 alive 0;
  print_list 40 5 [red] 12 20 dead 0;
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
  print_object 23 3 [Bold;yellow] screen_height ["ALIVE"];
  print_object 40 3 [Bold;yellow] screen_height ["DEAD"];
  print_object 40 15 [Bold;white;on_blue] screen_height [" CHAT LOG "];
  ()


let new_prompt () =
  set_cursor 2 (screen_height-1);
  erase Eol;
  print_string [] "> "


let () =
  show_banner ();
  show_state_and_chat();
  update_announcements test_a;
  update_chat test_c;
  update_game_state (-1) "LOBBY" alive dead;
  new_prompt ();


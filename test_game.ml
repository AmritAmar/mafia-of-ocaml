open OUnit2
open Game
open Core
open Data

let id_lst = ["Rachel";"Tyler";"Michael";"Irene"]
let plr_lst = [("Irene",Innocent);("Michael",Innocent);("Tyler",Innocent);("Rachel",Mafia)]
let kill_irene = [("Irene",Dead);("Michael",Innocent);("Tyler",Innocent);("Rachel",Mafia)]
let kill_tyler = [("Irene",Innocent);("Michael",Innocent);("Tyler",Dead);("Rachel",Mafia)]

let init_state = {day_count = 0; stage = Voting; 
        players = plr_lst;  
        announcement_history = []}
let state2 = {day_count = 1; stage = Discussion; 
        players = kill_tyler;  
        announcement_history = [(Time.now (),
             (All,"Good Morning! Last night, Tyler was killed in their sleep by the Mafia :( RIP."))]}
let vote_kill_irene = handle_exec_vote init_state ["Irene";"Irene";"Rachel";"Michael"]
let vote_kill_irene2 = handle_exec_vote init_state ["Irene";"Rachel";"Michael";"Irene"]
let vote_kill_irene3 = handle_exec_vote init_state ["Irene";"Michael";"Michael";"Irene"]
let client_json1 = [{player_id = "Irene";player_action = "vote";arguments = ["Michael"]};
					{player_id = "Michael";player_action = "vote";arguments = ["Michael"]};
					{player_id = "Tyler";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Rachel";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Irene";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Rachel";player_action = "vote";arguments = ["Tyler"]}]
let latest_client_json1 = 
					[{player_id = "Rachel";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Irene";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Tyler";player_action = "vote";arguments = ["Tyler"]};
					{player_id = "Michael";player_action = "vote";arguments = ["Michael"]}
					]
let vote_no_majority = handle_exec_vote init_state ["Irene";"Tyler";"Michael";"Rachel"]


let game_tests = [
  "assign_roles" >:: (fun _ -> assert_equal 
  	plr_lst
    (assign_roles 0 [] id_lst (List.length id_lst)));
  "kill_player" >:: (fun _ -> assert_equal kill_irene
    (kill_player "Irene" plr_lst));
  "handle_exec_vote_no_m" >:: (fun _ -> assert_equal plr_lst
    (vote_no_majority.players));
  "handle_exec_vote_inno1" >:: (fun _ -> assert_equal kill_irene
  	(vote_kill_irene.players));
   "handle_exec_vote_inno3" >:: (fun _ -> assert_equal kill_irene
  	(vote_kill_irene2.players));

  "handle_exec_vote_amb" >:: (fun _ -> assert_equal kill_irene
  	(vote_kill_irene3.players)); (* ambiguous!!! *)
  "latest_votes" >:: (fun _ -> assert_equal latest_client_json1
    ((latest_votes [] client_json1)));
  "night_to_disc" >:: (fun _ -> assert_equal (state2.day_count)
    ((night_to_disc init_state client_json1).day_count));
 
]

let other_tests = []

let _ = run_test_tt_main ("suite" >::: game_tests @ other_tests)

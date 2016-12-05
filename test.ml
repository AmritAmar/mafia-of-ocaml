open OUnit2
open Data

let data_tests = [
  "encode_sjson" >:: (fun _ -> assert_equal
    ("{\"day_count\":5,\"game_stage\":\"Night\",\"active_players\":"
    ^ "[\"Tyler\",\"Rachel\"],\"new_announcements\":[],\"new_messages\":"
    ^ "[{\"target\":\"mafia\",\"player_id\":\"Tyler\",\"message\":"
    ^ "\"dank meme\"}],\"timestamp\":\"today\"}")
    (encode_sjson { day_count=5;
                    game_stage="Night";
                    active_players=["Tyler";"Rachel"];
                    new_announcements=[];
                    new_messages=[("mafia","Tyler","dank meme")];
                    timestamp="today" })
    );
  "encode_cjson" >:: (fun _ -> assert_equal
    ("{\"player_id\":\"Tyler\",\"player_action\":\"CHAT\",\"arguments\":"
    ^ "[\"Tyler: dank may-mays\",\"Tyler: delet this\"]}")
    (encode_cjson { player_id="Tyler";
                    player_action="CHAT";
                    arguments=["Tyler: dank may-mays";"Tyler: delet this"] })
    );
  "decode_sjson" >:: (fun _ -> assert_equal
    { day_count=15;
      game_stage="VOTING";
      active_players=["Michael";"Irene"];
      new_announcements=[("ALL","Fresh dank memes are available. "
                                ^ "Get them while they're hot!")];
      new_messages=[("ALL","Irene","lel")];
      timestamp="YESTERDAY" }
    (decode_sjson
      ("{\"day_count\":15,\"game_stage\":\"VOTING\",\"active_players\":"
      ^ "[\"Michael\",\"Irene\"],\"new_announcements\":[{\"type\":\"ALL\","
      ^ "\"text\":\"Fresh dank memes are available. Get them while they're "
      ^ "hot!\"}],\"new_messages\":"
      ^ "[{\"target\":\"ALL\",\"player_id\":\"Irene\",\"message\":\"lel\"}],"
      ^ "\"timestamp\":\"YESTERDAY\"}"))
    );
  "decode_cjson" >:: (fun _ -> assert_equal
    { player_id="Tyler Compiler";
      player_action="COMMAND";
      arguments=["KILL";"CamelMan"] }
    (decode_cjson
      ("{\"player_id\":\"Tyler Compiler\",\"player_action\":\"COMMAND\","
      ^ "\"arguments\":[\"KILL\",\"CamelMan\"]}"))
    );
]

let other_tests = []

let _ = run_test_tt_main ("suite" >::: data_tests @ other_tests)

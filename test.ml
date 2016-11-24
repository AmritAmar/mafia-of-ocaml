open OUnit2
open Data

let data_tests = [
  "encode_sjson" >:: (fun _ -> assert_equal
    ("{\"day_count\":5,\"game_stage\":\"NIGHT\",\"active_players\":"
    ^ "[\"Tyler\",\"Rachel\"],\"new_announcements\":[],\"new_messages\":"
    ^ "[\"Tyler: dank meme\"]}")
    (encode_sjson { day_count=5;
                    game_stage="NIGHT";
                    active_players=["Tyler";"Rachel"];
                    new_announcements=[];
                    new_messages=["Tyler: dank meme"] })
    );
  "encode_cjson" >:: (fun _ -> assert_equal
    ("{\"player_id\":2,\"player_action\":\"CHAT\",\"arguments\":"
    ^ "[\"Rachel: dank may-mays\",\"Tyler: delet this\"]}")
    (encode_cjson { player_id=2;
                    player_action="CHAT";
                    arguments=["Rachel: dank may-mays";"Tyler: delet this"] })
    );
  "decode_sjson" >:: (fun _ -> assert_equal
    { day_count=15;
      game_stage="VOTING";
      active_players=["Michael";"Irene"];
      new_announcements=["Fresh dank memes are available. Get them while they're hot!"];
      new_messages=["Irene: lel"] }
    (decode_sjson
      ("{\"day_count\":15,\"game_stage\":\"VOTING\",\"active_players\":"
      ^ "[\"Michael\",\"Irene\"],\"new_announcements\":[\"Fresh dank memes "
      ^ "are available. Get them while they're hot!\"],\"new_messages\":"
      ^ "[\"Irene: lel\"]}"))
    );
  "decode_cjson" >:: (fun _ -> assert_equal
    { player_id=420;
      player_action="COMMAND";
      arguments=["KILL";"CamelMan"] }
    (decode_cjson
      ("{\"player_id\":420,\"player_action\":\"COMMAND\",\"arguments\":"
      ^ "[\"KILL\",\"CamelMan\"]}"))
    );
]

let other_tests = []

let _ = run_test_tt_main ("suite" >::: data_tests @ other_tests)

server:
	corebuild game_server.native -pkg cohttp.async -pkg yojson && ./game_server.native
test:
	corebuild -pkgs yojson,ANSITerminal,oUnit test.byte && ./test.byte

client:
	corebuild -pkgs yojson,async,lwt,cohttp,cohttp.async client.byte

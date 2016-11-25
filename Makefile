server:
	corebuild game_server.native -pkg cohttp.async && ./game_server.native
test:
	corebuild -pkgs yojson,ANSITerminal,oUnit test.byte && ./test.byte

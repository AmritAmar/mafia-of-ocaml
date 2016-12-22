default:
	@echo "Usage:"
	@echo "  make test                      runs tests"
	@echo "  make client URL=[server URL]   runs client and connects to server"
	@echo "  make server                    runs server"
	@echo "  make game                      runs game"
	@echo "  make test_game                 runs test_game"
	@echo "  make clean                     removes _build folder and .byte files"

daemon:
	corebuild -pkgs async,cohttp.async daemon.byte && ./daemon.byte

server:
	corebuild -pkgs cohttp.async,yojson game_server.byte && ./game_server.byte

client:
	corebuild -pkgs yojson,str,async,lwt,cohttp,cohttp.async,ANSITerminal client.byte && ./client.byte ${URL}

game:
	corebuild -pkgs yojson game.byte && ./game.byte

test:
	corebuild -pkgs yojson,ansiterminal,ounit test_game.byte && ./test_game.byte

clean:
	rm -rf _build *.byte

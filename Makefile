default:
	@echo "Usage:"
	@echo "  make test                      runs tests"
	@echo "  make client URL=[server URL]   runs client and connects to server"
	@echo "  make server                    runs server"
	@echo "  make game                      runs game"

server:
	corebuild -pkgs cohttp.async,yojson game_server.byte && ./game_server.byte

test:
	corebuild -pkgs yojson,ansiterminal,ounit test.byte && ./test.byte

client:
	corebuild -pkgs yojson,str,async,lwt,cohttp,cohttp.async,ansiterminal\
client.byte && ./client.byte ${URL}

game:
	corebuild -pkgs yojson game.byte && ./game.byte


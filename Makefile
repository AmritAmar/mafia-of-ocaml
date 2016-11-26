default:
	@echo "Usage:"
	@echo "  make test      runs tests"
	@echo "  make client    compiles client"
	@echo "  make server    runs server"

server:
	corebuild -pkgs cohttp.async,yojson game_server.byte && ./game_server.byte 

test:
	corebuild -pkgs yojson,ANSITerminal,oUnit test.byte && ./test.byte

client:
	corebuild -pkgs yojson,async,lwt,cohttp,cohttp.async client.byte && ./client.byte ${URL}

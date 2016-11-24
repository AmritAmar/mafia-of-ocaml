test:
	ocamlbuild -pkgs yojson,ANSITerminal,oUnit test.byte && ./test.byte

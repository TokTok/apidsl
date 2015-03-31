all:
	ocamlbuild -use-ocamlfind apigen.native && ./apigen.native

clean:
	ocamlbuild -clean

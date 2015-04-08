all:
	ocamlbuild -use-ocamlfind apigen.native && ./apigen.native tox.h

clean:
	ocamlbuild -clean

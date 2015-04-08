all:
	ocamlbuild -use-ocamlfind apigen.native
	./apigen.native tox.h
	./apigen.native toxav.h

clean:
	ocamlbuild -clean

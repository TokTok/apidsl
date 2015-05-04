tests: $(patsubst %.h,%.out,$(wildcard tests/*.h))

tests/%.out: tests/%.h all
	-./apigen.native $< > $@ 2>&1
	diff -u $@ tests/$*.exp
	rm -f $@

all:
	ocamlbuild -use-ocamlfind -yaccflag --table apigen.native

clean:
	ocamlbuild -clean

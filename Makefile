tests: $(patsubst %.h,%.out,$(wildcard src/tests/*.h))

src/tests/%.out: src/tests/%.h all
	-cd src && ../apigen.native $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u $@ src/tests/$*.exp
	rm -f $@

all:
	ocamlbuild -use-ocamlfind -yaccflag --table apigen.native

clean:
	ocamlbuild -clean

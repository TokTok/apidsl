tests: $(patsubst %.api.h,%.out.h,$(wildcard src/tests/*.h))

src/tests/%.out.h: src/tests/%.api.h all
	-cd src && ../apigen.native $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u $@ src/tests/$*.exp.h
	rm -f $@

all:
	ocamlbuild -use-ocamlfind -yaccflag --table apigen.native

clean:
	ocamlbuild -clean

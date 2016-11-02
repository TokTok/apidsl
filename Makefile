tests:	\
	$(patsubst %.api.h,%.out.h,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.hs,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.api,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.ast,$(wildcard src/tests/*.api.h))
	./apigen.native

src/tests/%.out.h: src/tests/%.api.h apigen.native
	-cd src && ../apigen.native -c $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.h $@
	rm -f $@

src/tests/%.out.hs: src/tests/%.api.h apigen.native
	-cd src && ../apigen.native -hs Main $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.hs $@
	rm -f $@

src/tests/%.out.api: src/tests/%.api.h apigen.native
	-cd src && ../apigen.native -api $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.api $@
	rm -f $@

src/tests/%.out.ast: src/tests/%.api.h apigen.native
	-cd src && ../apigen.native -ast $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.ast $@

apigen.native:
	ocamlbuild -use-ocamlfind -yaccflag --table apigen.native

clean:
	ocamlbuild -clean

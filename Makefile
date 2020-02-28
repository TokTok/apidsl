tests:	\
	$(patsubst %.api.h,%.out.h,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.hs,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.api,$(wildcard src/tests/*.api.h)) \
	$(patsubst %.api.h,%.out.ast,$(wildcard src/tests/*.api.h))
	./apigen.exe

src/tests/%.out.h: src/tests/%.api.h apigen.exe
	-cd src && ../apigen.exe $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.h $@
	rm -f $@

src/tests/%.out.hs: src/tests/%.api.h apigen.exe
	-cd src && ../apigen.exe -hs Main $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.hs $@
	rm -f $@

src/tests/%.out.api: src/tests/%.api.h apigen.exe
	-cd src && ../apigen.exe -api $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.api $@
	rm -f $@

src/tests/%.out.ast: src/tests/%.api.h apigen.exe
	-cd src && ../apigen.exe -ast $(patsubst src/%,%,$<) > $(patsubst src/%,%,$@) 2>&1
	diff -u src/tests/$*.exp.ast $@

apigen.exe:
	dune build --profile release
	cp _build/default/src/apigen.exe $@

coverage: travis-coveralls.sh
	bash $<

clean:
	dune clean

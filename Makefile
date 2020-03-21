apigen.native: $(wildcard *.ml* src/*.ml*)
	dune clean
	dune build --profile release
	cp _build/default/apigen.exe $@

test/%/dune: test/dune-template Makefile
	sed -e 's/%NAME%/$*/g' $< > $@

check: $(patsubst %,%dune,$(dir $(wildcard test/*/*.api.h)))
	dune clean
	BISECT_ENABLE=yes dune runtest

coverage: check
	bisect-ppx-report -html _coverage/ -I _build/default _build/default/test/*/bisect*.coverage

coveralls: check
	bisect-ppx-report \
		-coveralls coverage.json \
		-service-name travis-ci \
		-service-job-id "${TRAVIS_JOB_ID}" \
		-I _build/default _build/default/test/*/bisect*.coverage
	curl -L -F json_file=@coverage.json https://coveralls.io/api/v1/jobs

clean:
	dune clean
	rm -f apigen.native

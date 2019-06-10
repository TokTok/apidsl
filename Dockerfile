FROM ocaml/opam:alpine-3.15-ocaml-4.13-flambda-fp

RUN opam init --disable-sandboxing && opam update && opam install -y \
 bisect_ppx \
 dune \
 js_of_ocaml-ppx \
 ppx_deriving \
 ppx_deriving_yojson \ 
 tiny_httpd
CMD cp /apidsl /tmp/apidsl-dirty -R \
 && cd /tmp/apidsl-dirty \
 && eval $(opam env) \
 && make \
 && chmod 755 apigen.native \
 && cp apigen.native /apidsl/

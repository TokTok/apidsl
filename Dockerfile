FROM debian:stretch-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      ca-certificates \
      git \
      m4 \
      make \
      opam && \
    wget https://github.com/ocaml/opam/releases/download/2.0.6/opam-2.0.6-x86_64-linux -O /usr/bin/opam && \
    opam init --disable-sandboxing && \
    opam env && \
    opam install -y dune ppx_deriving menhir

CMD cp /apidsl /tmp/apidsl-dirty -R && \
    cd /tmp/apidsl-dirty && \
    eval $(opam env) && \
    make && \
    cp apigen.exe /apidsl

FROM debian:jessie-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      ca-certificates \
      git \
      m4 \
      make \
      opam && \
    rm -rf /var/lib/apt/lists/* \
    wget http://caml.inria.fr/pub/distrib/ocaml-4.03/ocaml-4.03.0.tar.gz && \
    tar -xzf ocaml* && \
    cd ocaml* && \
    ./configure -no-graph && \
    export MAKEFLAGS="-j $(nproc)" && \
    make world && \
    make opt && \
    make opt.opt && \
    make install && \
    cd .. && \
    rm -rf \
      ./ocaml* \
      /tmp/* \
      /var/tmp/*

CMD cp /apidsl /tmp/apidsl-dirty -R && \
    cd /tmp/apidsl-dirty && \
    PATH=/root/.opam/system/bin:/usr/local/bin:$PATH && \
    opam init && \
    opam config env && \
    opam install -y ocamlfind ppx_deriving menhir && \
    make && \
    cp apigen.native /apidsl

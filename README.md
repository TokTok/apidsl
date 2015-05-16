# APIDSL
A [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) for **C** API's to add consistency of naming schemes and comments.

## INSTALLATION
You will need **OCaml** (>= 4.02; older versions may not work) and **OPAM** (>= 1.2). Instructions on how to install **OCaml** and **OPAM** can be found [here](https://opam.ocaml.org/doc/Install.html).

### Installing dependencies:
Make sure to configure **OPAM** by running ``opam init``. (Depending on your configuration you might also need to run ``eval `opam config env` ``).
Running ``opam install ocamlfind ppx_deriving menhir`` should install all dependencies required for APIDSL.

### Compiling
Just run ``make`` in APIDSL's root directory. The apidsl binary can be found under ``./_build/apigen.native``

## USAGE
TODO, but you can check some examples in tests directory.

# APIDSL

A [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) for **C** API's
to add consistency of naming schemes and comments.

## INSTALLATION

### Regular

You will need **OCaml** (>= 4.03; older versions may not work) and **OPAM** (at
least 1.2). Instructions on how to install **OCaml** and **OPAM** can be found
[here](https://opam.ocaml.org/doc/Install.html).

For `make coverage` you also need `oasis` and `bisect_ppx`. The coverage script
will attempt to install these if they are not yet installed.

#### Installing dependencies:

Make sure to configure **OPAM** by running ``opam init``. (Depending on your
configuration you might also need to run ``eval `opam config env` ``).  Running
``opam install ocamlfind ppx_deriving menhir`` should install all dependencies
required for APIDSL.

#### Compiling

Just run ``make`` in APIDSL's root directory. The apidsl binary can be found
under ``./_build/apigen.native``

### Docker

Alternatively, you can use Docker to build APIDSL. This is useful when your
Linux distribution doesn't have the versions of dependencies required for APIDSL
or you don't want to pollute your system by installing all those dependencies.

#### Usage

[Get Docker on your system](https://docs.docker.com/engine/installation/linux/).
Note that some versions of
[Debian](https://packages.debian.org/search?suite=all&searchon=names&keywords=docker.io)
and [Ubuntu](http://packages.ubuntu.com/search?suite=all&searchon=names&keywords=docker.io)
have it in their package repository.

Run the following. It takes about 4 minutes to run on my machine, so you can
grab a cup of coffee/tea in the meantime.

```sh
# Clone this repository
git clone https://github.com/TokTok/apidsl
cd apidsl
# Build "apidsl" Docker image based on Dockerfile instructions
docker build -t apidsl .
# Run the image, i.e. execute the CMD part of the Dockerfile, mounting the
# current directory (the APIDSL repository) as /apidsl inside the image
docker run --rm -v $PWD:/apidsl apidsl
# Make sure apigen.native has appeared in the current directory
ls -lbh apigen.native
# Copy it over to /usr/local/bin
sudo cp ./apigen.native /usr/local/bin/
# Delete the image we have built
docker rmi apidsl debian:jessie-slim
# Make sure there are no containers or images left, as
# they take a lot of disk space and are not needed anymore
docker ps -a
docker images -a
```

You should now have `/usr/local/bin/apigen.native`.

## USAGE

TODO, but you can check some examples in tests directory.

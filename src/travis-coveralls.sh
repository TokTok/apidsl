#!/bin/bash
set -e
# Make sure we're not echoing any sensitive data
set +x

function instrument_oasis {
  sed -i -e 's/\(BuildDepends:\s*\)\(.*\)/\1bisect_ppx, \2/' _oasis
  if [ -f ../.coverage.excludes ]; then
    ln -s ../.coverage.excludes
    sed -i -e '/ByteOpt:/ s/$/ -ppxopt bisect_ppx,"-exclude-file ..\/.coverage.excludes"/' _oasis
    sed -i -e '/NativeOpt:/ s/$/ -ppxopt bisect_ppx,"-exclude-file ..\/.coverage.excludes"/' _oasis
  fi
  oasis setup
}

function instrument_omake {
  find . -name OMakefile -exec sed -i -e 's/\(OCAMLPACKS\s\++\?=\)/\1 bisect_ppx/' {} \;
}

CONFIGURE=${COV_CONF:-'echo "COV_CONF unset, assuming: <noop>"'}
BUILD=${COV_BUILD:-'echo "COV_BUILD unset, assuming: make"; make'}
TEST=${COV_TEST:-'echo "COV_TEST unset, assuming: make test"; make test'}
COVERAGE_DIR=.coverage/

rm -rf $COVERAGE_DIR
mkdir -p $COVERAGE_DIR
pushd $COVERAGE_DIR
if [ -z "$KEEP" ]; then trap "popd; rm -rf $COVERAGE_DIR" EXIT; fi

$(which cp) -r ../* .

eval `opam config env`
opam install -y bisect_ppx oasis ocveralls

if [ -f _oasis ] ; then
  instrument_oasis
elif [ -f OMakefile ] ; then
  instrument_omake
else
  echo Cannot instrument this build
  exit 1
fi

eval ${CONFIGURE}
eval ${BUILD}
find . -name 'bisect*' -delete
eval ${TEST}

find . -name 'bisect*' -exec mv {} . \;

DIRECTORIES=`find . -type d`
printf -v INCLUDES " -I %s" $DIRECTORIES

bisect-ppx-report bisect*.out $INCLUDES -text report
bisect-ppx-report bisect*.out $INCLUDES -summary-only -text summary
bisect-ppx-report bisect*.out $INCLUDES -html report-html

if [ -n "$TRAVIS" ]; then
  echo "\$TRAVIS set; running ocveralls and sending to coveralls.io..."
  ocveralls --prefix _build bisect*.out --send
else
  echo "\$TRAVIS not set; displaying results of bisect-ppx-report..."
  cat report
  cat summary
fi

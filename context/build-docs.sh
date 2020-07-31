#!/bin/bash -e

cd

export ENVOY_REPO=(${ENVOY_REPO:-https://github.com/envoyproxy/envoy})
# export GOPATH="$(pwd)/going"
# export PATH="$PATH:$(pwd)/bin"
# export BUILDOZER_BIN="$GOPATH/bin/buildozer"
# export BUILD_DIR="$(pwd)/build"

whoami
pwd
ulimit -s
getconf ARG_MAX

mkdir -p /source
cd /source

echo "BUILDING DOCS ${ENVOY_REPO[@]}"

git clone "${ENVOY_REPO[@]}"

cd envoy
# mkdir build_docs

# export ENVOY_SRCDIR="$(pwd)"
#

export LLVM_ROOT="/usr/lib/llvm-10"


# mkdir -p build

# ci/do_ci.sh docs

export ENVOY_SRCDIR="$(pwd)"
# export SRCDIR="$(pwd)"
# . ci/setup_cache.sh

echo ". $(pwd)/ci/build_setup.sh  && $(pwd)/docs/build.sh"  > /source/envoy/ci/build-envoy-docs.sh
chmod +x  /source/envoy/ci/build-envoy-docs.sh
/source/envoy/ci/build-envoy-docs.sh

echo "BUILDING DOCS COMPLETE"

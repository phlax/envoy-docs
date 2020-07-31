#!/bin/bash -e

export ENVOY_REPO=(${ENVOY_REPO:-https://github.com/envoyproxy/envoy})

whoami
ulimit -s
getconf ARG_MAX

mkdir -p /source
cd /source

if [ -d /source/envoy ]; then
    echo "Building docs from mounted source"
elif [ -n "${ENVOY_REPO[@]}" ]; then
    echo "Building docs from clone: ${ENVOY_REPO[@]}"
    git clone "${ENVOY_REPO[@]}"
fi

cd envoy

# the executed script needs to be in the ci folder for build_setup.sh to work
echo ". $(pwd)/ci/build_setup.sh  && $(pwd)/docs/build.sh" \
     > /source/envoy/ci/build-envoy-docs.sh
chmod +x  /source/envoy/ci/build-envoy-docs.sh
/source/envoy/ci/build-envoy-docs.sh
rm /source/envoy/ci/build-envoy-docs.sh

#!/bin/bash

opt_version=
while getopts 'pv:m:?h' c
do
  case $c in
    v)   opt_version=$OPTARG ;;
    ?|h) printf "Usage: %s [-p] [-v mono-ver]\n" $0 
         printf " -v  run specified mono version\n"
         exit 2
  esac
done
# NOTE:
# each container has a 1gb tmpfs mounted since it greatly speeds up the normally intensive db operations
# make sure that the docker host has enough memory to handle about ~300 MB per container, so 2-3 GB total
# excess goes to the swap and will slow down the entire system

# Preferred versions
MONO_VERSIONS="6.4 6.0 5.20 5.18"

# Future versions
MONO_VERSIONS="$MONO_VERSIONS 6.6=preview-xenial"

# Supported versions 
MONO_VERSIONS="$MONO_VERSIONS 5.16 5.14 5.12 5.10"

if [ "$opt_version" != "" ]; then
    MONO_VERSIONS="$opt_version"
fi

prepOne() {
    local MONO_VERSION_PAIR=$1

    MONO_VERSION_SPLIT=(${MONO_VERSION_PAIR//=/ })
    MONO_VERSION=${MONO_VERSION_SPLIT[0]}
    MONO_URL=${MONO_VERSION_SPLIT[1]:-"stable-xenial/snapshots/$MONO_VERSION"}

    echo "Building Test Docker for mono $MONO_VERSION"
    
    docker build -t radarr/testimages:mono-$MONO_VERSION --build-arg MONO_VERSION=$MONO_VERSION --build-arg MONO_URL=$MONO_URL --file mono/complete/Dockerfile mono
}

for MONO_VERSION_PAIR in $MONO_VERSIONS; do
    prepOne "$MONO_VERSION_PAIR"
done

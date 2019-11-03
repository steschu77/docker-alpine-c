#!/bin/sh

set -e

export BUILD_ROOT=$(pwd)
export CCACHE_DIR=${BUILD_ROOT}/.ccache

# Download and extract the cache from a previous (master) build.
# In case of errors continue with an empty cache.
# This should actually go into your CI script.
wget -O ccache.tar.gz "https://gitlab.com/api/v4/projects/.../jobs/artifacts/master/raw/ccache.tar.gz?job=..." || true
tar -xzf ccache.tar.gz || true

# Configure ccache and hook it into the compiler tool-chain
ccache --set-config=max_size=50.0M
export PATH="/usr/lib/ccache/bin:$PATH"

# Build your project.
mkdir .build || true ; cd .build
cmake -GNinja $1
time -p ninja

# Finally compress the cache and show some stats.
# Uploading artifacts should be handled by your CI
cd ${BUILD_ROOT}
tar -czf ccache.tar.gz .ccache
ccache -s

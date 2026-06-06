#!/bin/bash
set -ex

# osx: VW's find_external_library(OPENBLAS) globs ${PREFIX}/lib/libopenblas.dylib,
# but some osx conda libopenblas builds ship only the versioned .0.dylib with no
# unversioned symlink -> cmake "list GET given empty list". Create the symlink.
if [ "$(uname)" = "Darwin" ] && [ ! -e "${PREFIX}/lib/libopenblas.dylib" ]; then
    ob=$(cd "${PREFIX}/lib" && ls libopenblas.*.dylib libopenblasp-*.dylib 2>/dev/null | head -1)
    [ -n "$ob" ] && ln -sf "$ob" "${PREFIX}/lib/libopenblas.dylib"
fi

# aarch64: VW's src/vw/CMakeLists.txt only disables SSE for Darwin+arm64, so on
# Linux aarch64 it adds -msse4.1 (x86-only, rejected by gcc). Strip both flags.
if [ "$(uname -m)" = "aarch64" ]; then
    perl -i -pe 's/-mno-sse4\.1//g; s/-msse4\.1//g;' src/vw/CMakeLists.txt
fi

mkdir -p build && cd build
cmake ..                                         \
    -DCMAKE_PREFIX_PATH=${PREFIX}                \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
    -DASP_DEPS_DIR=${PREFIX}                     \
    -DUSE_OPENEXR=OFF                            \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT} install

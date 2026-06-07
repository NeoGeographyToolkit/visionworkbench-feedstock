#!/bin/bash
set -ex

# osx: VW's find_external_library(OPENBLAS) globs ${PREFIX}/lib/libopenblas.dylib,
# but some osx conda libopenblas builds ship only the versioned .0.dylib with no
# unversioned symlink -> cmake "list GET given empty list". Create the symlink.
if [ "$(uname)" = "Darwin" ] && [ ! -e "${PREFIX}/lib/libopenblas.dylib" ]; then
    ob=$(cd "${PREFIX}/lib" && ls libopenblas.*.dylib libopenblasp-*.dylib 2>/dev/null | head -1)
    [ -n "$ob" ] && ln -sf "$ob" "${PREFIX}/lib/libopenblas.dylib"
fi

# aarch64: VW tag 3.7.0 only disables SSE for Darwin+arm64, so on Linux aarch64
# it sets VW_ENABLE_SSE=1 -> SGM.h #includes <emmintrin.h> (x86 SSE2 header,
# absent on aarch64) AND adds -msse4.1 (rejected by gcc). Force VW_ENABLE_SSE=0
# (VW has a scalar SGM fallback) and strip the x86 flags. The build is aarch64,
# so flipping the default-1 to 0 is unambiguous here.
# TODO(oalexan1): upstream VW fix (god/master 9a2a4dd1: arm64|aarch64) not in
# tag 3.7.0; drop this when the feedstock source includes it.
if [ "$(uname -m)" = "aarch64" ]; then
    perl -i -pe 's/set\(VW_ENABLE_SSE 1\)/set(VW_ENABLE_SSE 0)/; s/-mno-sse4\.1//g; s/-msse4\.1//g;' src/vw/CMakeLists.txt
fi

mkdir -p build && cd build
cmake ..                                         \
    -DCMAKE_PREFIX_PATH=${PREFIX}                \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
    -DASP_DEPS_DIR=${PREFIX}                     \
    -DUSE_OPENEXR=OFF                            \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT} install

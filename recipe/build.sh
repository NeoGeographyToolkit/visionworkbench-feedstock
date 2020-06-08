#!/bin/bash

set -e

mkdir build
cd build

# Fix for missing liblzma.
perl -pi -e "s#(/[^\s]*?lib)/lib([^\s]+).la#-L\$1 -l\$2#g" ${PREFIX}/lib/*.la

echo "PREFIX=${PREFIX}"

cmake ..                                        \
    -DCMAKE_BUILD_TYPE=Release                  \
    -DCMAKE_PREFIX_PATH=${PREFIX}               \
    -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}       \
    -DCMAKE_CXX_FLAGS="-g -O3"                  \
    -DBoost_INCLUDE_DIR=${BUILD_PREFIX}/include \
    -DISIS_DEPS_DIR=${BUILD_PREFIX}             \
    -DBINARYBUILDER_INSTALL_DIR=${BUILD_PREFIX} \
    -DCMAKE_VERBOSE_MAKEFILE=ON                 \
    # -DVW_ENABLE_SSE=0 #  on pfe

make -j${CPU_COUNT}
make install



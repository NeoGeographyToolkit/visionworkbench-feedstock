#!/bin/bash

mkdir build
cd build

echo prefix is $PREFIX

# Only GCC 5 is supported for now. May need to have a check here.

GCC_DIR=$(dirname $(dirname $(which gcc)))
cmake ..                                  \
    -DCMAKE_CXX_FLAGS="-g -O3 -B$GCC_DIR" \
    -DBoost_INCLUDE_DIR=$PREFIX/include   \
    -DISIS_DEPS_DIR=$PREFIX               \
    -DBINARYBUILDER_INSTALL_DIR=$PREFIX   \
    -DCMAKE_VERBOSE_MAKEFILE=ON           \
    -DCMAKE_C_COMPILER=$GCC_DIR/bin/gcc   \
    -DCMAKE_CXX_COMPILER=$GCC_DIR/bin/g++
    # -DVW_ENABLE_SSE=0 #  on pfe

make -j${CPU_COUNT}
make install



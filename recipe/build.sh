#!/bin/bash

set -e

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir build
cd build

# Recommended in https://gitter.im/conda-forge/conda-forge.github.io?at=5c40da7f95e17b45256960ce
find ${PREFIX}/lib -name '*.la' -delete

isMac=$(uname -s | grep Darwin)
if [ "$isMac" != "" ]; then
  # Having trouble with the conda compiler on the mac for ipfind and convert_pinhole_model  
  #opt="-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++"
  #echo old CXXFLAGS=$CXXFLAGS
  export CXXFLAGS=""
  opt=""
else
  opt=""
fi

cmake ..                             \
    $opt                             \
    -DCMAKE_PREFIX_PATH=${PREFIX}    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make -j${CPU_COUNT}
make install

# TODO(oalexan1): Wipe this for the next release as this tool will not be there
# This tool is not needed and conflicts with other tools
rm -fv ${PREFIX}/bin/blend


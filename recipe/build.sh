#!/bin/bash

set -e

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir build
cd build

# Recommended in https://gitter.im/conda-forge/conda-forge.github.io?at=5c40da7f95e17b45256960ce
find ${PREFIX}/lib -name '*.la' -delete

if [[ $target_platform =~ osx.* ]]; then
  # Having trouble with the conda compiler on the mac for ipfind and convert_pinhole_model
  # TODO(oalexan1): This may not be necessary anymore.
  export CXXFLAGS=""
fi

cmake ..                             \
    -DCMAKE_PREFIX_PATH=${PREFIX}    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make -j${CPU_COUNT}
make install

# TODO(oalexan1): Wipe this for the next release as this tool will not be there
# This tool is not needed and conflicts with other tools
rm -fv ${PREFIX}/bin/blend

# Fix for OSX linking problem
echo Target platform is $target_platform
if [[ $target_platform =~ osx.* ]]; then
  for tool in ${PREFIX}/bin/*; do
    # Use the below command to return status of 0 even if install_name_tool fails
    (install_name_tool -change /usr/lib/libc++.1.dylib @rpath/libc++.1.0.dylib $tool || echo "")
  done
fi


#!/bin/bash

set -e

baseDir=$PWD

scriptDir=$(dirname $0)
cd $scriptDir
scriptDir=$PWD
sourceDir="$scriptDir/.."
toolsDir="$sourceDir/Tools"

cd $baseDir

rm -rf build staging

prefix="$PWD/staging/usr"
mkdir -p $prefix

export PKG_CONFIG_PATH=$prefix/lib/pkgconfig

if [ ! -f zips/gtest.tgz ]; then
   mkdir -p zips
   cd zips
   wget -O gtest.tgz https://github.com/google/googletest/archive/release-1.8.0.tar.gz

   cd $baseDir
fi

mkdir -p build/gtest/src
cd build/gtest/src
tar xf ../../../zips/gtest.tgz --strip 1

cd ..
mkdir build
cd build

cmake -DCMAKE_CXX_FLAGS='-m32' -DCMAKE_C_FLAGS='-m32' -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$prefix ../src
make -j3 install

cd $baseDir

mkdir -p build/thunder-tools/build
cd build/thunder-tools/build

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DGENERIC_CMAKE_MODULE_PATH=$prefix/share/cmake/Modules $toolsDir
make -j3 install

cd $baseDir

mkdir -p build/thunder/build
cd build/thunder/build

cmake -DCMAKE_C_FLAGS='-m32' -DCMAKE_CXX_FLAGS='-m32' -DBUILD_TYPE=Debug -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_MODULE_PATH=$prefix/share/cmake/Modules -DBUILD_TESTS=ON $sourceDir

make -j3 install

cd $baseDir

echo 'Core unit test runner can be found here:'
echo "   $PWD/build/thunder/build/Tests/unit/core/WPEFramework_test_core"


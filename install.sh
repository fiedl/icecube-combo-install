#!/bin/bash

# This script provides instructions on how to install the icecube-combo
# framework on macOS.
#
# https://github.com/fiedl/icecube-combo-install
#
# If you would like to use a release, set the `RELEASE` environment variable
# to the appropriate icecube-combo release number.
#
#     export RELEASE=V00-00-00-RC2
#
# If you would like to use the current `svn trunk`, set the `RELEASE` environment
# variable to "trunk".
#
#     export RELEASE=trunk
#
# In this repository, the `RELEASE` environment varibale is set by the
# github-actions build matrix.

[[ -z "$RELEASE" ]] && echo "Please set the RELEASE environment variable, e.g.: 'export RELEASE=V00-00-00-RC2' or 'export RELEASE=trunk'." && exit 1

# Homebrew paths
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Python path when installed via homebrew
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# Install Homebrew package manager (http://brew.sh):
if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# On docker, the user is already root, but `sudo` is missing.
if [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  which sudo || (apt-get update && apt-get install -y sudo)
fi

# Install fundamentals
if [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  sudo apt-get update
  sudo apt-get install -y subversion # svn
fi

# Install python 3
if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  brew info python
  brew list python || brew install python
elif [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  sudo apt-get install -y python3 virtualenv
  virtualenv -p /usr/bin/python3 py3env
  source py3env/bin/activate
fi

# Install boost with python bindings
if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  brew info boost
  brew install fiedl/homebrew-icecube/boost@1.69
  brew info boost-python
  brew info boost-python3
  brew install fiedl/homebrew-icecube/boost-python3@1.69
elif [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  sudo apt-get install -y libboost-all-dev libboost-python1.65.1
fi

# Install python packages
pip install numpy
pip install scipy

# Install packages needed for building icecube-combo
if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  brew list cmake || brew install cmake
  brew install gsl cfitsio
elif [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  sudo apt-get install -y build-essential cmake
  sudo apt-get install -y libz-dev libgsl0-dev libcfitsio-dev
  # http://software.icecube.wisc.edu/documentation/projects/cmake/supported_platforms/debian_variants.html
  # sudo apt-get install build-essential cmake libbz2-dev libgl1-mesa-dev freeglut3-dev libxml2-dev subversion libboost-python-dev libboost-system-dev libboost-thread-dev libboost-date-time-dev libboost-serialization-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev libgsl0-dev libcdk5-dev libarchive-dev python-scipy ipython-qtconsole libqt4-dev python-urwid
  # sudo apt-get install libz-dev libqt5opengl5-dev libstarlink-pal-dev python-sphinx libopenblas-dev
  # sudo apt-get install libcfitsio-dev libsprng2-dev libmysqlclient-dev libsuitesparse-dev
fi

# Install opencl
if [[ "$PLATFORM" = "ubuntu-18.04" ]]; then
  sudo apt-get install -y ocl-icd-opencl-dev
fi

# Install qt5 needed for steamshovel event display viewer
if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  brew info qt
  brew install qt
  #brew install pyqt
fi

## Install packages from icecube sources, e.g. random number generator
#brew tap IceCube-SPNO/homebrew-icecube
#brew install pal sprng2 cppzmq

# This is where the icecube software will live
export ICECUBE_ROOT="$HOME/icecube/software"
export ICECUBE_COMBO_ROOT=$ICECUBE_ROOT/icecube-combo-$RELEASE
export ICECUBE_COMBO=$ICECUBE_COMBO_ROOT/debug_build

# Get icecube-combo code from svn repository
mkdir -p $ICECUBE_COMBO_ROOT
if [ ! -d $ICECUBE_COMBO_ROOT/src ]; then
  if [[ -z $SVN_ICECUBE_USERNAME ]]; then
    source .secrets.sh
  fi
  if [[ $RELEASE =~ "-RC" ]]; then
    export SVN_PATH="meta-projects/combo/candidates/$RELEASE"
  elif [[ $RELEASE = "stable" ]]; then
    export SVN_PATH="meta-projects/combo/stable"
  elif [[ $RELEASE = "trunk" ]]; then
    export SVN_PATH="meta-projects/combo/trunk"
  else
    export SVN_PATH="meta-projects/combo/releases/$RELEASE"
  fi
  svn --username $SVN_ICECUBE_USERNAME --password $SVN_ICECUBE_PASSWORD co $SVN/$SVN_PATH/ $ICECUBE_COMBO_ROOT/src
fi

# Exclude projects if requested by environment variable,
# which is used on travis to avoid the execution-time limit
if [[ ! -z $EXCLUDE_PROJECTS ]]; then
  for project in $EXCLUDE_PROJECTS; do
    rm -rf $ICECUBE_COMBO_ROOT/src/$project
  done
fi

if [[ "$PLATFORM" = "macOS-10.14" ]]; then
  # Patch cmake file to find pymalloc version of python installed by homebrew
  # https://github.com/fiedl/hole-ice-install/issues/1
  patch --force $ICECUBE_COMBO_ROOT/src/cmake/tools/python.cmake < ./patches/python.cmake.patch
fi

#if [[ $RELEASE = "V06-01-01" ]]; then
#
#
#  # Patch muongun pybindings to add missing static cast
#  # https://github.com/fiedl/hole-ice-install/issues/2
#  if [[ -d $ICECUBE_COMBO_ROOT/src/MuonGun ]]; then
#    patch --force $ICECUBE_COMBO_ROOT/src/MuonGun/private/pybindings/histogram.cxx < ./patches/muongun-histogram.cxx.patch
#  fi
#
#  # Patch cmake file to drop requirement of the boost_signals library,
#  # which has been dropped in boost 1.69
#  # https://github.com/fiedl/hole-ice-install/issues/3
#  # https://code.icecube.wisc.edu/projects/icecube/ticket/2232
#  patch --force $ICECUBE_COMBO_ROOT/src/cmake/tools/boost.cmake < ./patches/boost.cmake.patch
#
#fi

# Build the release (debug)
mkdir -p $ICECUBE_COMBO_ROOT/debug_build
cd $ICECUBE_COMBO_ROOT/debug_build
cmake -D CMAKE_BUILD_TYPE=Debug -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Debug ../src
# source ./env-shell.sh  # <--- is this needed here?
make -j 6

# # Build the release
# mkdir -p $ICECUBE_COMBO_ROOT/build
# cd $ICECUBE_COMBO_ROOT/build
# cmake -D CMAKE_BUILD_TYPE=Release -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Release ../src
# ./env-shell.sh
# make -j 2


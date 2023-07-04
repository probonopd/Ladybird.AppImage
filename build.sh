#!/bin/sh

# https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructionsLadybird.md

git clone --depth 1 https://github.com/SerenityOS/serenity # TODO: Only the path at /Ladybird

cd serenity/Ladybird
ls

sudo apt-get -y install build-essential cmake libgl1-mesa-dev ninja-build qt6-base-dev qt6-tools-dev-tools qt6-multimedia-dev qt6-wayland gcc-12

# Ladybird needs gcc-12, so make it the default
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
gcc --version

# Export CC environment variable to force gcc-12
export CC=$(which gcc-12)

# The above is still not enough, so uninstall gcc-11
sudo apt-get -y remove gcc-11

# Build in Build/
mkdir -p Build/
cmake -GNinja -S . -B Build/
# optionally, add -DCMAKE_CXX_COMPILER=<suitable compiler> -DCMAKE_C_COMPILER=<matching c compiler>
cmake --build Build/
ninja -C Build/ run

#!/bin/sh

# https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructionsLadybird.md

git clone --depth 1 https://github.com/SerenityOS/serenity # TODO: Only the path at /Ladybird

cd serenity/Ladybird
ls

sudo apt-get -y install build-essential cmake libgl1-mesa-dev ninja-build qt6-base-dev qt6-tools-dev-tools qt6-multimedia-dev qt6-wayland clang-15 clang++-15

# Export CC environment variable to force clang-15 with ccache
export CC="ccache clang-15"
export CXX="ccache clang++-15"

# Build in Build/
mkdir -p Build/
cmake -GNinja -S . -B Build/
# optionally, add -DCMAKE_CXX_COMPILER=<suitable compiler> -DCMAKE_C_COMPILER=<matching c compiler>
cmake --build Build/
ninja -C Build/ run

find Build/
wget -c -q "https://github.com/probonopd/go-appimage/suites/14058685897/artifacts/785575955" --trust-server-names

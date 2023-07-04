#!/bin/sh

# git clone only the path at https://github.com/SerenityOS/serenity/tree/master/Ladybird with depth 1
git clone --depth 1 --no-checkout https://github.com/SerenityOS/serenity.git serenity
cd serenity
git sparse-checkout init --cone
git sparse-checkout set Ladybird

cd Ladybird
ls

sudo apt-get -y install build-essential cmake libgl1-mesa-dev ninja-build qt6-base-dev qt6-tools-dev-tools qt6-multimedia-dev qt6-wayland

# Build in Build/ladybird
mkdir -p Build/ladybird
cmake -GNinja -S Ladybird -B Build/ladybird
# optionally, add -DCMAKE_CXX_COMPILER=<suitable compiler> -DCMAKE_C_COMPILER=<matching c compiler>
cmake --build Build/ladybird
ninja -C Build/ladybird run

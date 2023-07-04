#!/bin/sh

# https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructionsLadybird.md

#
# Install build dependencies
#

sudo apt-get -y install build-essential cmake libgl1-mesa-dev ninja-build qt6-base-dev qt6-tools-dev-tools qt6-multimedia-dev qt6-wayland clang-15 clang++-15 zsync

#
# Get Ladybird source
#

git clone --depth 1 https://github.com/SerenityOS/serenity # TODO: Only the path at /Ladybird

#
# Build Ladybird
#

cd serenity/Ladybird
ls

# Export CC environment variable to force clang-15 with ccache
export CC="ccache clang-15"
export CXX="ccache clang++-15"

# Build in Build/
mkdir -p Build/
cmake -GNinja -S . -B Build/
# optionally, add -DCMAKE_CXX_COMPILER=<suitable compiler> -DCMAKE_C_COMPILER=<matching c compiler>
cmake --build Build/

find Build/
ldd Build/ladybird
ls -lh Build/

#
# Populate AppDir
#

# FIXME: If Ladybird had the equivalent of "make install", it would be so much nicer...

mkdir -p Ladybird.AppDir/usr/bin Ladybird.AppDir/usr/share/applications Ladybird.AppDir/usr/share/icons/hicolor/256x256/apps Ladybird.AppDir/usr/lib
cp Build/ladybird Ladybird.AppDir/usr/bin/
strip Ladybird.AppDir/usr/bin/ladybird
wget -c -q https://ladybird.dev/ladybird.png && mv ladybird.png Ladybird.AppDir/usr/share/icons/hicolor/256x256/apps/

cat > Ladybird.AppDir/usr/share/applications/ladybird.desktop <<\EOF
[Desktop Entry]
Version=1.0
Name=Ladybird
Comment=Ladybird is an ongoing project to build an independent web browser from scratch
Exec=ladybird
Icon=ladybird
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF
cp Ladybird.AppDir/usr/share/applications/ladybird.desktop Ladybird.AppDir/

#
# Deploy all dependencies into AppDir
#

wget -c "https://github.com/probonopd/Ladybird.AppImage/releases/download/assets/appimagetool-787-x86_64.AppImage"
# wget -c https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x appimagetool-*.AppImage

./appimagetool-*.AppImage -s deploy Ladybird.AppDir/usr/share/applications/*.desktop # Bundle EVERYTHING

#
# Turn AppDir into AppImage
#

VERSION=$(git rev-parse --short HEAD) ./appimagetool-*.AppImage ./Ladybird.AppDir

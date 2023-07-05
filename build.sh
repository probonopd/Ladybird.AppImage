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

# Similar to https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ladybird
cmake -GNinja -S . -B Build/ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX='/usr' -Wno-dev
ninja -C Build
DESTDIR="../Ladybird.AppDir/" ninja -C Build install # .. because it is relative to Build

find ./Ladybird.AppDir/

#
# Populate AppDir
#

# FIXME: If Ladybird had the equivalent of "make install", it would be so much nicer...

mkdir -p Ladybird.AppDir/usr/share/applications Ladybird.AppDir/usr/share/icons/hicolor/256x256/apps
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

wget -c https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x appimagetool-*.AppImage

./appimagetool-*.AppImage -s deploy Ladybird.AppDir/usr/share/applications/*.desktop # Bundle EVERYTHING

#
# Turn AppDir into AppImage
#

VERSION=$(git rev-parse --short HEAD) ./appimagetool-*.AppImage ./Ladybird.AppDir

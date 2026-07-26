#!/usr/bin/env bash
# UNRAID: local build/run helper for macOS development.
#
#   ./src/unraid/tools/dev.sh build     configure + build
#   ./src/unraid/tools/dev.sh run       build, then launch
#   ./src/unraid/tools/dev.sh run --dev build, then launch with the small
#                                       development image offered as an OS entry
#   ./src/unraid/tools/dev.sh dmg       build the DMG
#   ./src/unraid/tools/dev.sh test      build and run the unit tests
#   ./src/unraid/tools/dev.sh rpi       configure a stock Raspberry Pi Imager
#                                       build, to check the branding layer still
#                                       falls back cleanly
#
# Everything here is the documented flags from PORTING.md, wrapped up so they do
# not have to be retyped. Nothing in the build depends on this script.

set -euo pipefail

cd "$(dirname "$0")/../../.."   # repo root

QT_PREFIX="${QT_PREFIX:-/opt/homebrew/opt/qt}"
BUILD_DIR="${BUILD_DIR:-build}"
BUILD_TYPE="${BUILD_TYPE:-Debug}"
JOBS="${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}"

if [ ! -d "$QT_PREFIX" ]; then
    echo "Qt not found at $QT_PREFIX" >&2
    echo "Install it with:  brew install qt      (or set QT_PREFIX)" >&2
    exit 1
fi

configure() {
    # arm64 only: upstream defaults to a universal arm64;x86_64 build and
    # Homebrew's Qt is single-architecture, so the universal link fails.
    cmake -S src -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        "$@"
}

build() {
    configure
    cmake --build "$BUILD_DIR" -j "$JOBS"
}

app_binary() {
    echo "$BUILD_DIR/unraid-usb-creator.app/Contents/MacOS/unraid-usb-creator"
}

case "${1:-build}" in
    build)
        build
        echo "Built $(app_binary)"
        ;;

    run)
        build
        if [ "${2:-}" = "--dev" ]; then
            img="$BUILD_DIR/unraid-dev-image.zip"
            [ -f "$img" ] || ./src/unraid/tools/make-dev-image.sh "$img"
            echo "Launching with development image: $img"
            # Run in the foreground so qInfo() from the post-write step is visible;
            # that logging is the only way to confirm a write once the drive ejects.
            UNRAID_DEV_IMAGE="$PWD/$img" "$(app_binary)"
        else
            "$(app_binary)"
        fi
        ;;

    dmg)
        configure
        cmake --build "$BUILD_DIR" --target dmg -j "$JOBS"
        ls -lh "$BUILD_DIR"/*.dmg
        ;;

    test)
        cmake -S src -B build-test \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
            -DCMAKE_OSX_ARCHITECTURES=arm64 \
            -DBUILD_TESTING=ON
        cmake --build build-test --target unraid_guid_test -j "$JOBS"
        ./build-test/test/unraid_guid_test
        ;;

    rpi)
        # Confirms the branding layer still degrades to stock upstream.
        configure -DIMAGER_BRAND=rpi -B build-rpi
        echo "Configured a stock Raspberry Pi Imager build in build-rpi/"
        ;;

    *)
        sed -n '2,18p' "$0" | sed 's|^# \{0,1\}||'
        exit 1
        ;;
esac

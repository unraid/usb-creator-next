#!/bin/bash
set -e

# Script to create AppImage for embedded systems using EGLFS
# This creates an AppImage that runs with direct rendering (no window manager required)

# Parse command line arguments
ARCH=$(uname -m)  # Default to current architecture
CLEAN_BUILD=1
QT_ROOT_ARG=""
FORCE_EGLFS_BUILD=0

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --arch=ARCH            Target architecture (x86_64, aarch64, armv7l)"
    echo "  --qt-root=PATH         Path to Qt installation directory"
    echo "  --no-clean             Don't clean build directory"
    echo "  --force-eglfs-build    Force building Qt with EGLFS if not detected"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "This script creates an AppImage optimized for embedded systems:"
    echo "  - Uses EGLFS for direct rendering (no X11/Wayland required)"
    echo "  - Optimized for headless/embedded environments"
    echo "  - Smaller size by excluding desktop-specific libraries"
    exit 1
}

for arg in "$@"; do
    case $arg in
        --arch=*)
            ARCH="${arg#*=}"
            ;;
        --qt-root=*)
            QT_ROOT_ARG="${arg#*=}"
            ;;
        --no-clean)
            CLEAN_BUILD=0
            ;;
        --force-eglfs-build)
            FORCE_EGLFS_BUILD=1
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $arg"
            usage
            ;;
    esac
done

# Validate architecture
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" && "$ARCH" != "armv7l" ]]; then
    echo "Error: Architecture must be one of: x86_64, aarch64, armv7l"
    exit 1
fi

echo "Building embedded AppImage for architecture: $ARCH"

# Extract project information from CMakeLists.txt
SOURCE_DIR="src/"
CMAKE_FILE="${SOURCE_DIR}CMakeLists.txt"

# Extract version components
MAJOR=$(grep -E "set\(IMAGER_VERSION_MAJOR [0-9]+" "$CMAKE_FILE" | sed 's/set(IMAGER_VERSION_MAJOR \([0-9]*\).*/\1/')
MINOR=$(grep -E "set\(IMAGER_VERSION_MINOR [0-9]+" "$CMAKE_FILE" | sed 's/set(IMAGER_VERSION_MINOR \([0-9]*\).*/\1/')
PATCH=$(grep -E "set\(IMAGER_VERSION_PATCH [0-9]+" "$CMAKE_FILE" | sed 's/set(IMAGER_VERSION_PATCH \([0-9]*\).*/\1/')
PROJECT_VERSION="$MAJOR.$MINOR.$PATCH"

# Extract project name (lowercase for AppImage naming convention)
PROJECT_NAME=$(grep "project(" "$CMAKE_FILE" | head -1 | sed 's/project(\([^[:space:]]*\).*/\1/' | tr '[:upper:]' '[:lower:]')

echo "Building $PROJECT_NAME version $PROJECT_VERSION for embedded systems"

# Check for Qt installation with EGLFS support
QT_VERSION=""
QT_DIR=""
HAS_EGLFS_SUPPORT=0

# Check if Qt root is specified via command line argument (highest priority)
if [ -n "$QT_ROOT_ARG" ]; then
    echo "Using Qt from command line argument: $QT_ROOT_ARG"
    QT_DIR="$QT_ROOT_ARG"
# Check if Qt6_ROOT is explicitly set in environment
elif [ -n "$Qt6_ROOT" ]; then
    echo "Using Qt from Qt6_ROOT environment variable: $Qt6_ROOT"
    QT_DIR="$Qt6_ROOT"
# Auto-detect Qt installation in /opt/Qt
else
    if [ -d "/opt/Qt" ]; then
        echo "Checking for Qt installations in /opt/Qt..."
        # Find the newest Qt6 version installed
        NEWEST_QT=$(find /opt/Qt -maxdepth 1 -type d -name "6.*" | sort -V | tail -n 1)
        if [ -n "$NEWEST_QT" ]; then
            QT_VERSION=$(basename "$NEWEST_QT")
            
            # Find appropriate compiler directory for the architecture
            if [ "$ARCH" = "x86_64" ]; then
                if [ -d "$NEWEST_QT/gcc_64" ]; then
                    QT_DIR="$NEWEST_QT/gcc_64"
                fi
            elif [ "$ARCH" = "aarch64" ]; then
                if [ -d "$NEWEST_QT/gcc_arm64" ]; then
                    QT_DIR="$NEWEST_QT/gcc_arm64"
                fi
            elif [ "$ARCH" = "armv7l" ]; then
                if [ -d "$NEWEST_QT/gcc_arm32" ]; then
                    QT_DIR="$NEWEST_QT/gcc_arm32"
                fi
            fi
            
            if [ -n "$QT_DIR" ]; then
                echo "Found Qt $QT_VERSION for $ARCH at $QT_DIR"
            else
                echo "Found Qt $QT_VERSION, but no binary directory for $ARCH"
                QT_VERSION=""
            fi
        fi
    fi
fi

# If Qt not found, suggest building it with EGLFS support
if [ -z "$QT_DIR" ]; then
    echo "Error: No suitable Qt installation found for $ARCH"
    
    if [ -f "./build-qt.sh" ]; then
        echo "You can build Qt with EGLFS support using:"
        echo "  ./build-qt.sh --version=6.9.0 --use-eglfs --rpi-optimize"
        echo "Or specify the Qt location with:"
        echo "  $0 --qt-root=/path/to/qt"
    else
        echo "You can specify the Qt location with:"
        echo "  $0 --qt-root=/path/to/qt"
    fi
    
    exit 1
fi

# Check if Qt has EGLFS support
if [ -f "$QT_DIR/bin/qmake" ]; then
    QT_VERSION=$("$QT_DIR/bin/qmake" -query QT_VERSION)
    echo "Qt version: $QT_VERSION"
    
    # Check for EGLFS platform plugin
    if [ -f "$QT_DIR/plugins/platforms/libqeglfs.so" ] || [ -f "$QT_DIR/lib/libQt6EglFSDeviceIntegration.so" ]; then
        echo "✓ EGLFS support detected in Qt installation"
    else
        echo "⚠ Warning: EGLFS support not detected in Qt installation"
        if [ "$FORCE_EGLFS_BUILD" -eq 1 ]; then
            echo "Continuing anyway due to --force-eglfs-build flag"
        else
            echo "This may cause runtime issues. Use --force-eglfs-build to continue anyway."
            echo "For best results, rebuild Qt with EGLFS support:"
            echo "  ./build-qt.sh --version=$QT_VERSION --use-eglfs --rpi-optimize"
            exit 1
        fi
    fi
fi

# Configuration
BUILD_TYPE="MinSizeRel"  # Optimize for size in embedded systems
QML_SOURCES_PATH="$PWD/src/qmlcomponents/"

# Location of AppDir and output file
APPDIR="$PWD/AppDir-embedded-$ARCH"
OUTPUT_FILE="$PWD/Raspberry_Pi_Imager-${PROJECT_VERSION}-embedded-${ARCH}.AppImage"

# Tools directory for downloaded binaries
TOOLS_DIR="$PWD/appimage-tools"
mkdir -p "$TOOLS_DIR"

# Download linuxdeploy and plugins if they don't exist
echo "Ensuring linuxdeploy tools are available..."

# Choose the right linuxdeploy tools based on architecture
if [ "$ARCH" = "x86_64" ]; then
    LINUXDEPLOY="$TOOLS_DIR/linuxdeploy-x86_64.AppImage"
    LINUXDEPLOY_QT="$TOOLS_DIR/linuxdeploy-plugin-qt-x86_64.AppImage"
    
    if [ ! -f "$LINUXDEPLOY" ]; then
        echo "Downloading linuxdeploy for x86_64..."
        curl -L -o "$LINUXDEPLOY" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
        chmod +x "$LINUXDEPLOY"
    fi
    
    if [ ! -f "$LINUXDEPLOY_QT" ]; then
        echo "Downloading linuxdeploy-plugin-qt for x86_64..."
        curl -L -o "$LINUXDEPLOY_QT" "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
        chmod +x "$LINUXDEPLOY_QT"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    LINUXDEPLOY="$TOOLS_DIR/linuxdeploy-aarch64.AppImage"
    LINUXDEPLOY_QT="$TOOLS_DIR/linuxdeploy-plugin-qt-aarch64.AppImage"
    
    if [ ! -f "$LINUXDEPLOY" ]; then
        echo "Downloading linuxdeploy for aarch64..."
        curl -L -o "$LINUXDEPLOY" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-aarch64.AppImage"
        chmod +x "$LINUXDEPLOY"
    fi
    
    if [ ! -f "$LINUXDEPLOY_QT" ]; then
        echo "Downloading linuxdeploy-plugin-qt for aarch64..."
        curl -L -o "$LINUXDEPLOY_QT" "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-aarch64.AppImage"
        chmod +x "$LINUXDEPLOY_QT"
    fi
elif [ "$ARCH" = "armv7l" ]; then
    # Note: linuxdeploy may not have armv7l builds, fallback to manual deployment
    echo "Warning: linuxdeploy may not support armv7l, attempting manual deployment"
    LINUXDEPLOY=""
    LINUXDEPLOY_QT=""
fi

# Set up build directory
BUILD_DIR="build-embedded-$ARCH"

# Clean up previous builds if requested
if [ "$CLEAN_BUILD" -eq 1 ]; then
    echo "Cleaning previous build..."
    rm -rf "$APPDIR" "$BUILD_DIR"
fi

mkdir -p "$APPDIR"
mkdir -p "$BUILD_DIR"

echo "Building unraid-usb-creator for embedded $ARCH..."
# Configure and build with CMake
cd "$BUILD_DIR"

# Set architecture-specific CMake flags
CMAKE_EXTRA_FLAGS=""
if [ "$ARCH" = "aarch64" ] && [ "$(uname -m)" = "x86_64" ]; then
    # Cross-compiling from x86_64 to aarch64
    echo "Cross-compiling from $(uname -m) to $ARCH"
    CMAKE_EXTRA_FLAGS="-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64"
elif [ "$ARCH" = "armv7l" ] && [ "$(uname -m)" = "x86_64" ]; then
    # Cross-compiling from x86_64 to armv7l
    echo "Cross-compiling from $(uname -m) to $ARCH"
    CMAKE_EXTRA_FLAGS="-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm"
fi

# Add Qt path to CMake flags
CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS -DQt6_ROOT=$QT_DIR"

# shellcheck disable=SC2086
cmake "../$SOURCE_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DCMAKE_INSTALL_PREFIX=/usr $CMAKE_EXTRA_FLAGS
make -j$(nproc)

echo "Creating embedded AppDir..."
# Install to AppDir
make DESTDIR="$APPDIR" install
cd ..

# Copy the desktop file from debian directory and modify for embedded use
if [ ! -f "$APPDIR/usr/share/applications/com.limetech.unraid-usb-creator-embedded.desktop" ]; then
    mkdir -p "$APPDIR/usr/share/applications"
    cp "debian/com.limetech.unraid-usb-creator.desktop "$APPDIR/usr/share/applications/com.limetech.unraid-usb-creator-embedded.desktop"
    # Update the desktop file for embedded use
    sed -i 's|Name=.*|Name=Unraid Usb Creator (Embedded)|' "$APPDIR/usr/share/applications/com.limetech.unraid-usb-creator-embedded.desktop"
    sed -i 's|Comment=.*|Comment=Unraid USB Creator for embedded systems (EGLFS)|' "$APPDIR/usr/share/applications/com.limetech.unraid-usb-creator-embedded.desktop"
    sed -i 's|Exec=.*|Exec=unraid-usb-creator|' "$APPDIR/usr/share/applications/com.limetech.unraid-usb-creator-embedded.desktop"
fi

# Create the AppRun file optimized for EGLFS
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"

# Set up paths
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${HERE}/usr/plugins"
export QML_IMPORT_PATH="${HERE}/usr/qml"
export QT_QPA_PLATFORM_PLUGIN_PATH="${HERE}/usr/plugins/platforms"

# Configure Qt for EGLFS (embedded/direct rendering)
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=eglfs_kms
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1

# Disable desktop-specific features for embedded use
export QT_QUICK_CONTROLS_STYLE=Material
export QT_SCALE_FACTOR=1.0

# GPU memory optimization for embedded systems
export QT_QUICK_BACKEND=software
export QT_OPENGL=es2

# Logging (can be disabled in production)
export QT_LOGGING_RULES="*.debug=false;qt.qpa.eglfs.debug=true"

# Check if running on a framebuffer device
if [ -c /dev/fb0 ]; then
    export QT_QPA_EGLFS_FB=/dev/fb0
fi

# For systems with DRM/KMS
if [ -c /dev/dri/card0 ]; then
    export QT_QPA_EGLFS_KMS_DEVICE=/dev/dri/card0
fi

exec "${HERE}/usr/bin/unraid-usb-creator" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# Manual Qt deployment for embedded systems (optimized)
echo "Deploying Qt dependencies for embedded systems..."

if [ -n "$LINUXDEPLOY" ] && [ -f "$LINUXDEPLOY" ]; then
    # Use linuxdeploy if available
    export QML_SOURCES_PATHS="$QML_SOURCES_PATH"
    export APPIMAGE_EXTRACT_AND_RUN=1
    export QMAKE="$QT_DIR/bin/qmake"
    export LD_LIBRARY_PATH="$QT_DIR/lib:$LD_LIBRARY_PATH"
    
    # Deploy with exclusions for desktop-specific libraries
    "$LINUXDEPLOY" --appdir="$APPDIR" --plugin=qt \
        --exclude-library="libwayland-*" \
        --exclude-library="libX11*" \
        --exclude-library="libxcb*" \
        --exclude-library="libXext*" \
        --exclude-library="libXrender*"
else
    # Manual deployment for architectures without linuxdeploy support
    echo "Performing manual Qt deployment..."
    
    # Copy essential Qt libraries
    mkdir -p "$APPDIR/usr/lib"
    cp -d "$QT_DIR/lib/libQt6Core.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6Gui.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6Widgets.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6Quick.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6Qml.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6Network.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6OpenGL.so"* "$APPDIR/usr/lib/"
    cp -d "$QT_DIR/lib/libQt6EglFSDeviceIntegration.so"* "$APPDIR/usr/lib/" 2>/dev/null || true
    
    # Copy EGLFS platform plugin
    mkdir -p "$APPDIR/usr/plugins/platforms"
    cp "$QT_DIR/plugins/platforms/libqeglfs.so" "$APPDIR/usr/plugins/platforms/" 2>/dev/null || true
    cp -r "$QT_DIR/plugins/egldeviceintegrations" "$APPDIR/usr/plugins/" 2>/dev/null || true
    
    # Copy essential plugins (excluding desktop-specific ones)
    mkdir -p "$APPDIR/usr/plugins/imageformats"
    cp "$QT_DIR/plugins/imageformats/libqjpeg.so" "$APPDIR/usr/plugins/imageformats/" 2>/dev/null || true
    cp "$QT_DIR/plugins/imageformats/libqpng.so" "$APPDIR/usr/plugins/imageformats/" 2>/dev/null || true
    
    # Copy QML components
    if [ -d "$QT_DIR/qml" ]; then
        mkdir -p "$APPDIR/usr/qml"
        cp -r "$QT_DIR/qml/QtQuick" "$APPDIR/usr/qml/" 2>/dev/null || true
        cp -r "$QT_DIR/qml/QtQuick.2" "$APPDIR/usr/qml/" 2>/dev/null || true
        cp -r "$QT_DIR/qml/QtQml" "$APPDIR/usr/qml/" 2>/dev/null || true
    fi
fi

# Embedded-specific optimizations
echo "Applying embedded system optimizations..."

# Remove desktop-specific libraries that may have been included
rm -f "$APPDIR/usr/lib/libwayland"* 2>/dev/null || true
rm -f "$APPDIR/usr/lib/libX11"* 2>/dev/null || true
rm -f "$APPDIR/usr/lib/libxcb"* 2>/dev/null || true
rm -rf "$APPDIR/usr/plugins/platforms/libqwayland"* 2>/dev/null || true
rm -rf "$APPDIR/usr/plugins/platforms/libqxcb"* 2>/dev/null || true

# Remove development files to save space
find "$APPDIR" -name "*.a" -delete 2>/dev/null || true
find "$APPDIR" -name "*.la" -delete 2>/dev/null || true
find "$APPDIR" -name "*.prl" -delete 2>/dev/null || true

# Strip binaries to reduce size
find "$APPDIR" -type f -executable -exec strip {} \; 2>/dev/null || true

echo "Creating embedded AppImage..."
# Remove old AppImage symlink
rm -f "$PWD/unraid-usb-creator-embedded.AppImage"

if [ -n "$LINUXDEPLOY" ] && [ -f "$LINUXDEPLOY" ]; then
    # Create AppImage using linuxdeploy
    "$LINUXDEPLOY" --appdir="$APPDIR" --output=appimage
    
    # Rename the output file
    for appimage in *.AppImage; do
        if [ "$PWD/$appimage" != "$OUTPUT_FILE" ]; then
            mv "$appimage" "$OUTPUT_FILE"
        fi
    done
else
    # Manual AppImage creation (basic implementation)
    echo "Creating AppImage manually (basic implementation)..."
    # This is a simplified approach - for full AppImage creation,
    # you would need appimagetool or similar
    tar czf "${OUTPUT_FILE%.AppImage}.tar.gz" -C "$APPDIR" .
    echo "Created compressed archive: ${OUTPUT_FILE%.AppImage}.tar.gz"
    echo "Note: Full AppImage creation requires appimagetool for $ARCH"
fi

if [ -f "$OUTPUT_FILE" ]; then
    echo "Embedded AppImage created at $OUTPUT_FILE"
    
    # Create a symlink with a simpler name
    SYMLINK_NAME="$PWD/unraid-usb-creator-embedded.AppImage"
    if [ -L "$SYMLINK_NAME" ] || [ -f "$SYMLINK_NAME" ]; then
        rm -f "$SYMLINK_NAME"
    fi
    ln -s "$(basename "$OUTPUT_FILE")" "$SYMLINK_NAME"
    echo "Created symlink: $SYMLINK_NAME -> $(basename "$OUTPUT_FILE")"
    
    echo ""
    echo "Embedded AppImage build completed successfully for $ARCH architecture."
    echo ""
    echo "This AppImage is optimized for embedded systems:"
    echo "  - Uses EGLFS for direct rendering (no X11/Wayland required)"
    echo "  - Smaller size with desktop libraries excluded"
    echo "  - Configured for headless/embedded environments"
    echo ""
    echo "To run on embedded systems:"
    echo "  - Ensure /dev/dri/card0 is available"
    echo "  - Run directly: ./$(basename "$OUTPUT_FILE")"
    echo "  - No desktop environment required"
else
    echo "AppImage creation completed, but output file verification failed."
    echo "Check the build process for any errors."
fi 
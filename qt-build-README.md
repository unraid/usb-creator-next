# Building Qt for Raspberry Pi OS

This document explains how to build Qt from source with Debian-like configuration for Raspberry Pi OS using the `build-qt.sh` script.

## Overview

The `build-qt.sh` script automates the process of:
1. Installing dependencies required for building Qt
2. Downloading the Qt source code
3. Configuring it with optimizations for Raspberry Pi OS
4. Building and installing Qt to a specified location

By default, Qt is built to work with the Raspberry Pi OS Wayland-based desktop environment, but you can also configure it for direct rendering via EGLFS.

## Prerequisites

Before running the script, ensure you have:
- A Raspberry Pi running Raspberry Pi OS (Debian-based)
- At least 10GB of free disk space
- Internet connection to download packages and Qt source
- Sufficient RAM (at least 2GB, 4GB+ recommended)
- Optionally: a swap file if memory is limited

## Basic Usage

To build Qt with default options:

```bash
./build-qt.sh
```

This will:
- Build Qt 6.5.3
- Install it to `/opt/qt6`
- Use all available CPU cores
- Automatically detect and optimize for your Raspberry Pi model
- Configure for the Wayland desktop environment

## Command Line Options

The script supports the following options:

```
--version=VERSION    Qt version to build (default: 6.5.3)
--prefix=PREFIX      Installation prefix (default: /opt/qt6)
--cores=CORES        Number of CPU cores to use (default: all)
--no-clean           Don't clean the build directory
--debug              Build with debug information
--skip-dependencies  Skip installing build dependencies
--rpi-optimize       Apply Raspberry Pi specific optimizations
--use-eglfs          Configure for EGLFS (direct rendering) instead of Wayland
-h, --help           Show this help message
```

### Examples

Build a specific Qt version:
```bash
./build-qt.sh --version=6.6.1
```

Install to a custom location:
```bash
./build-qt.sh --prefix=/home/pi/qt6
```

Limit CPU usage (useful on low-end Raspberry Pi models):
```bash
./build-qt.sh --cores=2
```

Build for direct rendering (useful for full-screen or kiosk applications):
```bash
./build-qt.sh --use-eglfs
```

## Platform Configuration

### Wayland (Default)

By default, Qt is built to work with the Raspberry Pi OS desktop, which uses Wayland. This configuration is ideal for:
- Regular desktop applications
- Windowed applications
- Applications that need to work alongside other desktop software

### EGLFS (Optional)

If you specify the `--use-eglfs` option, Qt will be built for direct rendering. This configuration is better for:
- Full-screen applications
- Kiosk applications
- Embedded systems without a desktop environment
- Applications that need maximum GPU performance

## Raspberry Pi Optimizations

The script automatically detects Raspberry Pi models and applies appropriate optimizations:

- **Raspberry Pi 2**: Optimized for Cortex-A7
- **Raspberry Pi 3**: Optimized for Cortex-A53
- **Raspberry Pi 4**: Optimized for Cortex-A72
- **Raspberry Pi 5**: Optimized for Cortex-A76

These optimizations include:
- CPU-specific compiler flags
- OpenGL ES 2.0 support
- Platform-specific configurations (Wayland or EGLFS)
- Raspberry Pi specific dependencies

## Using the Built Qt

After building Qt, the script creates several helper files:

1. Environment setup script: `$PREFIX/bin/qtenv.sh`
2. CMake toolchain file: `$PREFIX/qt6-toolchain.cmake`
3. Platform-switching scripts: `$PREFIX/bin/qt-use-wayland.sh` and `$PREFIX/bin/qt-use-eglfs.sh`

### Setting up the environment

To set up your environment for using the built Qt:

```bash
source /opt/qt6/bin/qtenv.sh
```

This will set the needed environment variables for Qt.

### Switching between Wayland and EGLFS

Even if you built Qt for one platform, you can switch to the other at runtime:

For Wayland (desktop):
```bash
source /opt/qt6/bin/qt-use-wayland.sh
```

For EGLFS (direct rendering):
```bash
source /opt/qt6/bin/qt-use-eglfs.sh
```

### Building with CMake

To use this Qt build with CMake projects:

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=/opt/qt6/qt6-toolchain.cmake -S /path/to/source -B build
```

## Build Times

Be aware that building Qt from source can take a considerable amount of time:

- Raspberry Pi 5: approximately 2-4 hours
- Raspberry Pi 4: approximately 4-8 hours
- Raspberry Pi 3: approximately 10-20 hours
- Raspberry Pi 2: may take 24+ hours

## Troubleshooting

### Memory Issues

If the build process fails due to memory errors:

```bash
# Create a 4GB swap file
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add to fstab to persist across reboots
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

### Disk Space

Ensure you have at least 10GB free disk space. The build process requires:
- ~1GB for the Qt source code
- ~8GB for the build directory
- ~2GB for the installed Qt

### Build Failures

If the build fails:
1. Check the error message in the console output
2. Look for missing dependencies 
3. Try with fewer cores using `--cores=2`
4. Try building with `--debug` to get more verbose output

### Platform-Specific Issues

#### Wayland Issues
- If your application doesn't appear or has graphical glitches on Wayland, try forcing the XCB platform:
  ```bash
  export QT_QPA_PLATFORM=xcb
  ```

#### EGLFS Issues
- If you have issues with EGLFS display, you may need to adjust the KMS settings:
  ```bash
  export QT_QPA_EGLFS_KMS_CONFIG=/path/to/custom/eglfs.json
  ```

## Using with unraid-usb-creator

If you're building Qt specifically for the Raspberry Pi Imager:

1. Build Qt using this script
2. Modify the `create-appimage.sh` script to point to your Qt installation:

```bash
# Example: Add to create-appimage.sh
export Qt6_ROOT="/opt/Qt/6.9.0/gcc_arm64"
``` 
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
OUTPUT_DIR="${NATIVE_LIBS_OUTPUT_DIR:-$SCRIPT_DIR/../../resources/composemediaplayer/native}"

echo "=== Building Linux NativeVideoPlayer ==="
echo "Output dir: $OUTPUT_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"
if command -v cmake >/dev/null 2>&1; then
    cmake "$SCRIPT_DIR" -DCMAKE_BUILD_TYPE=Release
    cmake --build . --parallel
    ctest --output-on-failure --no-tests=error
elif [[ -f "$SCRIPT_DIR/prebuilt/libNativeVideoPlayer.so" ]]; then
    echo "cmake not found, using prebuilt libNativeVideoPlayer.so"
    mkdir -p "$OUTPUT_DIR/linux-x86-64"
    cp "$SCRIPT_DIR/prebuilt/libNativeVideoPlayer.so" "$OUTPUT_DIR/linux-x86-64/libNativeVideoPlayer.so"
else
    echo "Error: cmake is required to build NativeVideoPlayer from source" >&2
    exit 1
fi

echo "=== Build completed ==="

# Show output location
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        echo "Output: $OUTPUT_DIR/linux-x86-64/libNativeVideoPlayer.so"
        ;;
    aarch64|arm64)
        echo "Output: $OUTPUT_DIR/linux-aarch64/libNativeVideoPlayer.so"
        ;;
    *)
        echo "Output: $OUTPUT_DIR/linux-$ARCH/libNativeVideoPlayer.so"
        ;;
esac

#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Sets the target folders and the final framework product.
PROJECT_NAME=XCTestWD
FRAMEWORK_CONFIG=Release
BUILD_TARGET=XCTestWD

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
INSTALL_DIR="$SRCROOT/Frameworks/$BUILD_TARGET.framework"

# Working dir will be deleted after the framework creation.
WORK_DIR="$SRCROOT/build"
DEVICE_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphoneos/$BUILD_TARGET.framework"
SIMULATOR_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphonesimulator/$BUILD_TARGET.framework"
rm -rf "$WORK_DIR"

echo "Building device..."
xcodebuild -configuration "$FRAMEWORK_CONFIG" -target "$BUILD_TARGET" -sdk iphoneos -project "$PROJECT_NAME.xcodeproj" > /dev/null

echo "Building simulator..."
xcodebuild -configuration "$FRAMEWORK_CONFIG" -target "$BUILD_TARGET" -sdk iphonesimulator -project "$PROJECT_NAME.xcodeproj" > /dev/null

echo "Preparing directory..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/Headers"
mkdir -p "$INSTALL_DIR/Modules/$BUILD_TARGET.swiftmodule"

# Regulating Framework Deliverables
echo "Migrating System Headers:"
cp "$SIMULATOR_DIR/Headers/"*.h "$INSTALL_DIR/Headers/"

echo "Mixing Mutli-Architecture Swift Modules:"
cp "$SIMULATOR_DIR/Modules/module.modulemap" "$INSTALL_DIR/Modules/"
cp "$SIMULATOR_DIR/Modules/$BUILD_TARGET.swiftmodule/"* "$INSTALL_DIR/Modules/$BUILD_TARGET.swiftmodule/"
cp "$DEVICE_DIR/Modules/$BUILD_TARGET.swiftmodule/"* "$INSTALL_DIR/Modules/$BUILD_TARGET.swiftmodule/"
cp "$SIMULATOR_DIR/Info.plist" "$INSTALL_DIR/"

echo "Combine Fat File"
lipo -create "$DEVICE_DIR/$BUILD_TARGET" "$SIMULATOR_DIR/$BUILD_TARGET" -output "${INSTALL_DIR}/${BUILD_TARGET}"

# Clean Up Intermediate File
# rm -rf "$WORK_DIR"

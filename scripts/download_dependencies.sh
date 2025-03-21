#!/bin/bash
#
# https://github.com/arduino/Arduino/blob/master/hardware/package_index_bundled.json
# https://downloads.arduino.cc/packages/package_index.json

set -eu

DEPENDENCIES_DIR="deps"

ARM_PLATFORM_VERSION="1.0.9"
ARM_TOOLING_VERSION="4.8.3-2014q1-linux64"
ARM_TOOLING_BOSSAC_VERSION="1.6.1-arduino-x86_64-linux-gnu"
ARM_TOOLING_CMSIS_VERSION="4.0.0"

mkdir --parents $DEPENDENCIES_DIR

curl --location --output $DEPENDENCIES_DIR/adafruit-samd.tar.bz2 https://github.com/adafruit/arduino-board-index/raw/gh-pages/boards/adafruit-samd-$ARM_PLATFORM_VERSION.tar.bz2
tar --extract --file $DEPENDENCIES_DIR/adafruit-samd.tar.bz2 --directory $DEPENDENCIES_DIR
mv $DEPENDENCIES_DIR/$(tar --list --file $DEPENDENCIES_DIR/adafruit-samd.tar.bz2 | head --lines 1) $DEPENDENCIES_DIR/arm

curl --output $DEPENDENCIES_DIR/gcc-arm-none-eabi.tar.gz https://downloads.arduino.cc/gcc-arm-none-eabi-$ARM_TOOLING_VERSION.tar.gz
tar --extract --file $DEPENDENCIES_DIR/gcc-arm-none-eabi.tar.gz --directory $DEPENDENCIES_DIR
mv $DEPENDENCIES_DIR/$(tar --list --file $DEPENDENCIES_DIR/gcc-arm-none-eabi.tar.gz | head --lines 1) $DEPENDENCIES_DIR/gcc-arm

curl --output $DEPENDENCIES_DIR/bossac.tar.gz https://downloads.arduino.cc/bossac-$ARM_TOOLING_BOSSAC_VERSION.tar.gz
tar --extract --file $DEPENDENCIES_DIR/bossac.tar.gz --directory $DEPENDENCIES_DIR
mv $DEPENDENCIES_DIR/$(tar --list --file $DEPENDENCIES_DIR/bossac.tar.gz | head --lines 1) $DEPENDENCIES_DIR/bossac

curl --output $DEPENDENCIES_DIR/cmsis.tar.bz2 https://downloads.arduino.cc/CMSIS-$ARM_TOOLING_CMSIS_VERSION.tar.bz2
tar --extract --file $DEPENDENCIES_DIR/cmsis.tar.bz2 --directory $DEPENDENCIES_DIR
mv $DEPENDENCIES_DIR/$(tar --list --file $DEPENDENCIES_DIR/cmsis.tar.bz2 | head --lines 1) $DEPENDENCIES_DIR/cmsis

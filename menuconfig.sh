#!/bin/bash
# simple script for executing menuconfig

# root directory of NetHunter onyx git repo (default is this script's location)
RDIR=$(pwd)

# directory containing cross-compile arm toolchain
TOOLCHAIN=$HOME/build/toolchain/arm-cortex_a15-linux-gnueabihf-linaro_4.9.4-2015.06

############## SCARY NO-TOUCHY STUFF ###############

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN/bin/arm-eabi-

[ "$DEVICE" ] || DEVICE=onyx
[ "$TARGET" ] || TARGET=nethunter
DEFCONFIG=${TARGET}_${DEVICE}_defconfig
DEFCONFIG_FILE=$RDIR/arch/$ARCH/configs/$DEFCONFIG

[ -f "$DEFCONFIG_FILE" ] || {
	echo "Config $DEFCONFIG not found in $ARCH configs!"
	exit 1
}

cd "$RDIR"
echo "Cleaning build..."
rm -rf build
mkdir build
make -s -i -C "$RDIR" O=build $DEFCONFIG menuconfig
echo "Showing differences between old config and new config"
echo "-----------------------------------------------------"
command -v colordiff >/dev/null 2>&1 && {
	diff -Bwu --label "old config" "$DEFCONFIG_FILE" --label "new config" build/.config | colordiff
} || {
	diff -Bwu --label "old config" "$DEFCONFIG_FILE" --label "new config" build/.config
	echo "-----------------------------------------------------"
	echo "Consider installing the colordiff package to make diffs easier to read"
}
echo "-----------------------------------------------------"
echo -n "Are you satisfied with these changes? Y/N: "
read option
case $option in
y|Y)
	cp build/.config "$DEFCONFIG_FILE"
	echo "Copied new config to $DEFCONFIG_FILE"
	;;
*)
	echo "That's unfortunate"
	;;
esac
echo "Cleaning build..."
rm -rf build
echo "Done."

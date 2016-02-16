#!/bin/bash
# simple bash script for generating dtb image

RDIR=$(pwd)
DTBDIR=$RDIR/build/arch/arm/boot
DTSDIR=$RDIR/arch/arm/boot/dts/project

[ -d $DTBDIR ] || {
	echo "You need to run ./build.sh first!"
	exit 1
}

cd $DTSDIR

for prjdir in $(ls); do
	cd $DTSDIR/$prjdir
	for dts in $(ls *.dts); do
		$RDIR/build/scripts/dtc/dtc -p 1024 -O dtb -o $DTBDIR/${dts%.dts}.dtb $dts
	done
done

echo "Generating dtb.img..."
$RDIR/scripts/dtbTool/dtbTool -o $DTBDIR/dtb.img $DTBDIR/ -s 2048

echo "Done."

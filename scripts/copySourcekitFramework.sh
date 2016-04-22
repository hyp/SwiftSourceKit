#!/bin/sh

path=${BUILT_PRODUCTS_DIR}/externalFrameworks/
mkdir -p ${path}
sync

rm -rf ${path}/sourcekitd.framework
if [ "Release" = "${CONFIGURATION}" ]; then
	cp -a ${SRCROOT}/../build/Ninja-ReleaseAssert/swift-macosx-x86_64/lib/sourcekitd.framework ${path}
else
	cp -a ${SRCROOT}/../build/Ninja-DebugAssert/swift-macosx-x86_64/lib/sourcekitd.framework ${path}
fi

#!/bin/sh
#
# Fetches from the meta-freescale sources and
# creates subdirectory 'imx_features' containing regexp maps
# for aiding runtime decision about supported features based on SoC IDs.
#

set -euo pipefail

WHOAMI=$(basename "$0")
WHEREAMI=$(dirname "$0")
WHEREAMI=$(realpath "$WHEREAMI")

IMX_BASE_INC=$(mktemp)
cleanup() {
    rm -f $IMX_BASE_INC
}
trap cleanup EXIT

echo "$WHOAMI: fetching from meta-freescale sources..." >&2
wget -qO - 'https://raw.githubusercontent.com/Freescale/meta-freescale/dunfell/conf/machine/include/imx-base.inc' >$IMX_BASE_INC

MAP_DIR=${WHEREAMI}/imx_features
rm -rf $MAP_DIR
mkdir $MAP_DIR

map_feature() {
    FEATURE=$1
    MAP_FILE=$MAP_DIR/${FEATURE}.socs
    echo "$WHOAMI: SoCs flagged with '$FEATURE':" >&2
    sed -r \
        -e '/^MACHINEOVERRIDES_EXTENDER_mx[^[:blank:]]+ *=/!d' \
        -e '/\<'"$FEATURE"'\>/!d' \
        -e 's/ *=.*//' \
        -e 's/.*_//' \
        -e 'y/abcdefghijklmnopqrstuxwxyz/ABCDEFGHIJKLMNOPQRSTUXWXYZ/' \
        -e 's/^/^i\\./' \
        <$IMX_BASE_INC | \
    tee $MAP_FILE >&2
}

map_feature 'imxgpu'
map_feature 'imxdpu'

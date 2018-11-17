#!/bin/bash
set -euo pipefail

TMPROOTDIR="."
TMPDIR="${TMPROOTDIR}/EXPOSUREFUSION.$$"

cleanup() {
  rv=$?
  rm -rf $TMPDIR
  exit $rv
}

trap cleanup INT TERM EXIT

usage() {
    echo "Usage:"
    echo "  $(basename "$0") first_file.dng [colortemp [greenvalue]]"
}

error() {
    echo "$1"
    usage
    exit 1
}

command_check() {
    [[ -x "$(command -v "$1")" ]] || (echo "ERROR: $1 is not installed" && exit 2)
}

first_file=${1:-}
colortemp=${2-5500}
greenvalue=${3:-}

command_check "ufraw-batch"
command_check "parallel"
command_check "align_image_stack"
command_check "enfuse"
command_check "convert"
command_check "exiftool"

[[ -z "$first_file" ]] && error "NO INPUT FILE SPECIFIED"

input_file_base=$(basename "$first_file" .dng)
if [[ ${input_file_base} =~ ^([a-z_0-9]*)([0-9]{4}) ]]; then
 NUM=${BASH_REMATCH[2]}
 PREFIX=${BASH_REMATCH[1]}
else
 error "INVALID FILENAME: $first_file"
fi

mkdir "$TMPDIR" || error "CANNOT CREATE TEMPORARY FILE DIRECTORY"

x1=$(printf '%04d' $(( NUM )));
x2=$(printf '%04d' $(( NUM+1 )));
x3=$(printf '%04d' $(( NUM+2 )));
efname=${PREFIX}${x1}_ef

echo Using color temperature "${colortemp}"
greenparam=""
[[ ! -z ${greenvalue} ]] && greenparam="--green ${greenvalue}" && echo Using green "${greenvalue}"
parallel --no-notice ufraw-batch --temperature="${colortemp}" "${greenparam}" --out-type=png --out-path ${TMPDIR} ::: "${PREFIX}${x1}.dng" "${PREFIX}${x2}.dng" "${PREFIX}${x3}.dng"

align_image_stack -s 3 -a "${TMPDIR}/ais_${PREFIX}${x1}_" "${TMPDIR}/${PREFIX}"{"${x1}","${x2}","${x3}"}.png
enfuse -o "${TMPDIR}/${efname}.tif" "${TMPDIR}/ais_${PREFIX}${x1}"_*.tif
convert "${TMPDIR}/${efname}".{tif,jpg}
exiftool -TagsFromFile "${TMPDIR}/${PREFIX}${x1}.png" -all:all "${TMPDIR}/${efname}.jpg"
exiftool '-DateTimeOriginal>FileModifyDate' "${TMPDIR}/${efname}.jpg"
exiftool -P -keywords+="exposure fusion" "${TMPDIR}/${efname}.jpg"
mv "${TMPDIR}/${efname}.jpg" .

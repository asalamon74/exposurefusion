#!/usr/bin/env bash
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
    echo "  $(basename "$0") [options] first_file.dng"
    echo ""
    echo "  -h, --help                  display this help"
    echo "  -t, --temperature           color temperature"
    echo "  -g, --green                 green value"
    echo "  -n, --num                   number of images to process (default: 3)"
}

error() {
    echo "$1"
    usage
    exit 1
}

command_check() {
    [[ -x "$(command -v "$1")" ]] || (echo "ERROR: $1 is not installed" && exit 2)
}

colortemp=5500
greenvalue=
first_file=
num=3

for i in "$@"
do
case $i in
    -h|--help)
    usage
    exit
    ;;
    -t=*|--temperature=*)
    colortemp="${i#*=}"
    shift # past argument=value
    ;;
    --green=*)
    greenvalue="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--num=*)
    num="${i#*=}"
    shift # past argument=value
    ;;
    -*)
    echo "Unknown option $1"
    usage
    exit 1
    ;;
    *)
    if [[ -z "$first_file" ]]; then
        first_file=${i}
    else
        echo "Extra argument ${i}"
        usage
        exit 1
    fi
    ;;
esac
done

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

declare -a x
declare -a filenames

for i in $(seq 0 $((num-1))); do
    x[$i]=$(printf '%04d' $(( NUM + i )));
    filenames[$i]="${PREFIX}${x[$i]}.dng"
done

efname=${PREFIX}${x[0]}_ef

echo Using color temperature "${colortemp}"
greenparam=""
[[ -n ${greenvalue} ]] && greenparam="--green ${greenvalue}" && echo Using green "${greenvalue}"
parallel --no-notice ufraw-batch --temperature="${colortemp}" "${greenparam}" --out-type=png --out-path ${TMPDIR} ::: "${filenames[@]}"

align_image_stack -s 3 -a "${TMPDIR}/ais_${PREFIX}${x[0]}_" "${TMPDIR}/${PREFIX}"*.png
enfuse -o "${TMPDIR}/${efname}.tif" "${TMPDIR}/ais_${PREFIX}${x[0]}"_*.tif
convert "${TMPDIR}/${efname}".{tif,jpg}
exiftool -TagsFromFile "${TMPDIR}/${PREFIX}${x[0]}.png" -all:all "${TMPDIR}/${efname}.jpg"
exiftool '-DateTimeOriginal>FileModifyDate' "${TMPDIR}/${efname}.jpg"
exiftool -P -keywords+="exposure fusion" "${TMPDIR}/${efname}.jpg"
mv "${TMPDIR}/${efname}.jpg" .

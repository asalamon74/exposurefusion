#!/bin/bash
V=$(basename $1 .dng)
if [[ ${V} =~ ^([a-z_0-9]*)([0-9]{4}) ]]; then
 NUM=${BASH_REMATCH[2]}
 PREFIX=${BASH_REMATCH[1]}
else
 echo Invalid filename
 exit 1
fi
x1=`printf '%04d' $NUM`;
x2=`printf '%04d' $(( $NUM+1 ))`;
x3=`printf '%04d' $(( $NUM+2 ))`;
efname=${PREFIX}${x1}_ef
greenvalue=${3:-}
echo Using color temperature ${2-5500}
[[ ! -z ${greenvalue} ]] && greenparam="--green ${greenvalue}" && echo Using green ${greenvalue}
parallel --no-notice ufraw-batch --temperature=${2-5500} ${greenparam} --out-type=png ::: ${PREFIX}${x1}.dng ${PREFIX}${x2}.dng ${PREFIX}${x3}.dng
align_image_stack -s 3 -a ais_${PREFIX}${x1}_ ${PREFIX}${x1}.png ${PREFIX}${x2}.png ${PREFIX}${x3}.png
enfuse -o ${efname}.tif ais_${PREFIX}${x1}_*.tif
convert ${efname}.{tif,jpg}
exiftool -TagsFromFile ${PREFIX}${x1}.png -all:all ${efname}.jpg
exiftool '-DateTimeOriginal>FileModifyDate' ${efname}.jpg
exiftool -P -keywords+="exposure fusion"  ${efname}.jpg
rm ais_${PREFIX}${x1}_*.tif
rm ${efname}.tif
rm ${efname}.jpg_original
rm ${PREFIX}${x1}.png ${PREFIX}${x2}.png ${PREFIX}${x3}.png

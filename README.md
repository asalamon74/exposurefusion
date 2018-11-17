[![Build Status](https://travis-ci.org/asalamon74/exposure_fusion.svg?branch=master)](https://travis-ci.org/asalamon74/exposure_fusion)

# Exposure Fusion

Shell script for [exposure fusion](https://photo.stackexchange.com/a/20897/507). 

## Requirements

- [ufraw](http://ufraw.sourceforge.net/)
- [enfuse](https://wiki.panotools.org/Enfuse)
- [align_image_stack](https://wiki.panotools.org/Align_image_stack)
- [imagemagick](http://www.imagemagick.org)
- [exiftool](https://www.sno.phy.queensu.ca/~phil/exiftool/)
- [GNU parallel](https://www.gnu.org/software/parallel/)

## Usage

```
exposure_fusion.sh first_file.dng [colortemp [greenvalue]]
```

* first_file.dng: The first RAW input file.

* colortemp: Color temperature to use for RAW conversion. Default: 5500

* greenvalue: Gree value to use for RAW conversion.


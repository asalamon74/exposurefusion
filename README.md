[![Build Status](https://travis-ci.org/asalamon74/exposurefusion.svg?branch=master)](https://travis-ci.org/asalamon74/exposurefusion)

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
exposure_fusion.sh [options] first_file.dng

Options:
  -h, --help                  display this help
  -t, --temperature           color temperature
  -g, --green                 green value
```

* first_file.dng: The first RAW input file. The script will use the number
  in the file name to find the three input files. For instance if the
  first file is `aaa_1234.dng`, the script will use the following
  files: `aaa_1234.dng`, `aaa_1235.dng`, and `aaa_1236.dng`.

* color temperature: Color temperature to use for RAW conversion. Default: 5500

* green value: Green value to use for RAW conversion.


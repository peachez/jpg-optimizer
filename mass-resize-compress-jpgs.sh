#!/bin/bash

#######################################################################

# 1. Make sure you have the following installed:
#   imagemagick: (run "convert -v" if your not sure its installed)
#     https://imagemagick.org/ (find your OS and follow install guide)

#   MozJPEG image compressor: (run "mozcjpeg -v" if your not sure its installed)
#     https://imagecompressor.io/blog/mozjpeg-guide/

# With these installed, you should have the "convert" command and the "mozcjpeg" command
# available in your terminal. If not, check the docs, you missed something.

# Next, set the two variables below, "srcDir" and "destDir" with
# your source and destination directories.
# >>>> Make sure your destination directory exists before running this file.

# To run this file, open a terminal and run:
#   ~/Documents/scripts/mass-resize-compress-jpgs/mass-resize-compress-jpgs.sh > output-file.txt

# NOTE: The "> output-file.txt" is totally optional. As this file outputs each file
# converted, you probably dont want to bloat your terminal window with a
# buttload of filenames...your choice.

#######################################################################

srcDir="/Users/johndoe/Downloads/original_files"
destDir="/Users/johndoe/Downloads/original_files--resized" # make sure this dir exists
maxWidth="2000"

# Compress and save all jpeg/jpg files found recursively in source directory
function resizeMeJpg () {
  # "$1" # The file
  # "$2" # Escaped Source Directory, "$srcDir"
  # "$3" # Destination Directory, "$destDir", as defined at top of file.
  # "$4" # Max width of the new image

  # The input file from the srcDir (or nested within directories)
  input=$(echo "$1" | sed "s/\.\///")

  # The final destination file path and name
  dest="$3/$(echo "$1" | sed "$2")"

  if [ -z "$4" ] # is empty?
  then
    convert "$input" "$TMPDIR/temp.jpg"
  else
    convert "$input" -resize "$4x"\> "$TMPDIR/temp.jpg"
  fi

  mozcjpeg -progressive -quality 75 "$TMPDIR/temp.jpg" > "$dest"
  echo "$dest"
}

# These are use inside the find exec call below.
# We need to export them so they are available within its scope.
export -f resizeMeJpg
export maxWidth
export destDir
export escSrcDir="s/$(printf '%s\n' "$srcDir" | sed -e 's/[]\/$*.^[]/\\&/g')\/\.\///g"

# Main call of this file. Loops over each jpg file, as defined by its mime type,
# and calls the resizeMeJpg function above.
find "$srcDir/". -type f -exec sh -c '
    file --mime-type "$0" | grep -q image/jpeg\$ && resizeMeJpg "$0" "$escSrcDir" "$destDir" "$maxWidth"
' {} \;

# echo "=================="
# Compress and save all png files found recursively in source directory
# -- Currently this section is not developed as jpg were the only thing needed when this script was built.
# find "$srcDir/". -type f -exec sh -c '
#     file --mime-type "$0" | grep -q image/png\$ && echo "$0\n"
# ' {} \;
#!/bin/bash

# check if a directory path was provided
if [ -z "$1" ]; then
    echo "Error: Please provide a directory path."
    echo "Usage: bash organizer_ifelse.sh /path/to/directory"
    exit 1
fi

DIR="$1"
 
# verify the given path is a valid directory
if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a valid directory."
    exit 1
fi
 
echo "Organizing files in: $DIR"

# loop through all items in the directory
for FILE in "$DIR"/*; do
 
    # Skip subdirectories
    if [ -d "$FILE" ]; then
        continue
    fi
 
    # skip anything that is not a regular file
    if [ ! -f "$FILE" ]; then
        continue
    fi
 
    FILENAME=$(basename "$FILE")
    EXT="${FILENAME##*.}"
 
    # handle files without extensions
    if [ "$EXT" = "$FILENAME" ]; then
        EXT="no_extension"
    fi
 
    # convert extension to lowercase
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
 
    # decide destination folder based on extension
    if [ "$EXT" = "sv" ] || [ "$EXT" = "v" ] || [ "$EXT" = "vh" ]; then
        DEST_FOLDER="verilog"
 
    elif [ "$EXT" = "c" ] || [ "$EXT" = "h" ]; then
        DEST_FOLDER="c_code"
 
    elif [ "$EXT" = "cpp" ] || [ "$EXT" = "cc" ] || [ "$EXT" = "hpp" ]; then
        DEST_FOLDER="cpp_code"
 
    elif [ "$EXT" = "py" ]; then
        DEST_FOLDER="python"
 
    elif [ "$EXT" = "txt" ] || [ "$EXT" = "md" ] || [ "$EXT" = "pdf" ]; then
        DEST_FOLDER="docs"
 
    elif [ "$EXT" = "jpg" ] || [ "$EXT" = "jpeg" ] || [ "$EXT" = "png" ] || [ "$EXT" = "gif" ]; then
        DEST_FOLDER="images"
 
    elif [ "$EXT" = "sh" ] || [ "$EXT" = "bash" ]; then
        DEST_FOLDER="scripts"
 
    elif [ "$EXT" = "no_extension" ]; then
        DEST_FOLDER="no_extension"
 
    else
        DEST_FOLDER="other"
    fi
 
    # create destination folder if it does not exist
    mkdir -p "$DIR/$DEST_FOLDER"
 
    # move the file into its category folder
    mv "$FILE" "$DIR/$DEST_FOLDER/$FILENAME"
    echo "Moved: $FILENAME  →  $DEST_FOLDER/"
 
done
 
echo "All files have been organized."

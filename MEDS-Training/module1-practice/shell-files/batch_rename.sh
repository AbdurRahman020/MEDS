#!/bin/bash

# validate argument count
if [ "$#" -ne 3 ]; then
    echo "Error: Wrong number of arguments."
    echo "Usage: bash batch_rename.sh <old_pattern> <new_pattern> <directory>"
    echo "Example: bash batch_rename.sh 'old' 'new' /path/to/directory"
    exit 1
fi

# input arguments
PREFIX="$1"
SUFFIX="$2"
DIR="$3"

# ensure directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a valid directory."
    exit 1
fi

# prevent empty patterns
if [ -z "$PREFIX" ] || [ -z "$SUFFIX" ]; then
    echo "Error: Old and new patterns cannot be empty."
    exit 1
fi

# counters for summary
RENAME_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

echo "Batch Rename"
echo "Looking for: ${PREFIX}_old_<N>.sv"
echo "Renaming to: ${SUFFIX}_new_<N>.sv"
echo "Directory: $DIR"

# process all .sv files in the directory
for FILE in "$DIR"/*.sv; do

    # handle case where no .sv files exist
    if [ ! -f "$FILE" ]; then
        echo "No .sv files found in '$DIR'."
        exit 0
    fi

    FILENAME=$(basename "$FILE")

    # match files with the expected naming pattern
    if [[ $FILENAME == ${PREFIX}_old_*.sv ]]; then

        # extract numeric part from filename
        AFTER_PREFIX="${FILENAME#${PREFIX}_old_}"
        NUMBER="${AFTER_PREFIX%.sv}"

        # build new filename
        NEW_FILE_NAME="${SUFFIX}_new_${NUMBER}.sv"

        # avoid overwriting existing files
        if [ -f "$DIR/$NEW_FILE_NAME" ]; then
            echo "  SKIPPED: $FILENAME (target '$NEW_FILE_NAME' already exists.)"
            SKIP_COUNT=$((SKIP_COUNT + 1))
        else
            # rename file
            mv "$DIR/$FILENAME" "$DIR/$NEW_FILE_NAME"

            if [ "$?" -eq 0 ]; then
                echo "  RENAMED: $FILENAME -> $NEW_FILE_NAME"
                RENAME_COUNT=$((RENAME_COUNT + 1))
            else
                echo "  ERROR: Failed to rename '$FILENAME'."
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
        fi
    else
        # file does not match expected pattern
        echo "  SKIPPED: $FILENAME (does not match pattern.)"
        SKIP_COUNT=$((SKIP_COUNT + 1))
    fi

done

# print final summary
echo "Summary: $RENAME_COUNT renamed, $SKIP_COUNT skipped, $ERROR_COUNT errors."

# exit status based on results
if [ "$RENAME_COUNT" -eq 0 ]; then
    echo "No files were renamed."
    exit 0
elif [ "$ERROR_COUNT" -gt 0 ]; then
    echo "Batch rename completed with $ERROR_COUNT errors."
    exit 1
else
    echo "Batch rename completed successfully with $RENAME_COUNT files renamed."
    exit 0
fi
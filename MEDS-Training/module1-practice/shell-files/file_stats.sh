#!/bin/bash

# ensure a directory path is provided
if [ -z "$1" ]; then
	echo "Error: Please provide a directory path."
	echo "Usage: bash file_stats.sh /path/to/directory"
	exit 1
fi

DIR="$1"

# validate directory
if [ ! -d "$DIR" ]; then
	echo "Error: '$DIR' is not valid."
	exit 1
fi

echo "Stats for: $DIR"

# count regular files
FILE_COUNT=0

for ITEM in "$DIR"/*; do
	if [ -f "$ITEM" ]; then
		FILE_COUNT=$((FILE_COUNT + 1))
	fi
done

echo "Total files: $FILE_COUNT"

# count subdirectories
DIR_COUNT=0

for ITEM in "$DIR"/*; do
	if [ -d "$ITEM" ]; then
		DIR_COUNT=$((DIR_COUNT + 1))
	fi
done

echo "Total directories: $DIR_COUNT"

# track the largest file
LARGEST_NAME="(none)"
LARGEST_SIZE=0

for ITEM in "$DIR"/*; do
	if [ -f "$ITEM" ]; then
		SIZE=$(wc -c < "$ITEM")

		if [ "$SIZE" -gt "$LARGEST_SIZE" ]; then
			LARGEST_SIZE=$SIZE
			LARGEST_NAME=$(basename "$ITEM")
		fi
	fi
done

echo "Largest file: $LARGEST_NAME ($LARGEST_SIZE bytes)"

# track the most recently modified file
RECENT_NAME="(none)"
RECENT_TIME=0

for ITEM in "$DIR"/*; do
	if [ -f "$ITEM" ]; then
		MOD_TIME=$(stat -c %Y "$ITEM")

		if [ "$MOD_TIME" -gt "$RECENT_TIME" ]; then
			RECENT_TIME=$MOD_TIME
			RECENT_NAME=$(basename "$ITEM")
		fi
	fi
done

# format modification date if a recent file exists
if [ "$RECENT_NAME" != "(none)" ]; then
	RECENT_DATE=$(date -d "@$RECENT_TIME" "+%Y-%m-%d %H:%M:%S")
else
	RECENT_DATE="N/A"
fi

echo "Most recent file: $RECENT_NAME ($RECENT_DATE)"

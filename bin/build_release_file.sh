#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

mkdir ../builds

# Get the tag name from the GitHub Actions environment variable
TAG_NAME="${GITHUB_REF_NAME:-}"

# Validate the tag name using Python since macOS BSD grep lacks PCRE (-P) support
if ! python -c "import re, sys; sys.exit(0 if re.match(r'^\d+\.\d+(\.\d+)[a-z-]*?$', sys.argv[1]) else 1)" "$TAG_NAME"; then
    echo "Error: Tag '${TAG_NAME}' does not match the required format '^\d+\.\d+(\.\d+)[a-z-]*?$'." >&2
    exit 1
fi

echo "Tag '${TAG_NAME}' validated successfully. Starting the build process..."

# Execute the main build script with the required parameter
python ./build.py --build-tag="$TAG_NAME"

echo "Build completed successfully."

# Get the target of the latest-library symlink
cd ../builds
TARGET_DIR=$(readlink latest-library)
PARENT_DIR=$(dirname "$TARGET_DIR")
FOLDER_NAME=$(basename "$TARGET_DIR")

# Change into the parent directory so the zip contains just the folder
cd "$PARENT_DIR"

# Create the zip archive with maximum compression
zip -9 -r "../OpenSceneryX-${TAG_NAME}.zip" "$FOLDER_NAME"
echo "Created OpenSceneryX-${TAG_NAME}.zip successfully."

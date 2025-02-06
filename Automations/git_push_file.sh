#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <GitHub Username> <Repository Name>  [Target Directory in Repo] <File Path 1> <File Path 2> ... <File Path N>"
    exit 1
fi

# Assigning arguments
GITHUB_USERNAME=$1
REPO_NAME=$2
TARGET_DIR=$3
# Construct the GitHub repository URL
REPO_URL="git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"

shift 3 # Remove the first three arguments (GitHub username and repo name), leaving only folder paths

# If no target directory is provided, set it to the root directory
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="."
fi


# Clone the repository if it doesn't exist locally
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME" || exit
else
    cd "$REPO_NAME" || exit
    echo "Repository already exists. Using existing repository."
fi

# Create the target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ] && [ "$TARGET_DIR" != "." ]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Loop over the provided file paths
for FILE_PATH in "$@"; do
    # Convert to absolute path
    ABS_FILE_PATH=$(realpath "$FILE_PATH")

    # Check if the file exists
    if [ ! -f "$ABS_FILE_PATH" ]; then
        echo "Error: File '$ABS_FILE_PATH' does not exist!"
        continue
    fi

    # Copy the file to the target directory
    cp "$ABS_FILE_PATH" "$TARGET_DIR/"

    # Stage the file for commit
    git add "$TARGET_DIR/$(basename "$ABS_FILE_PATH")"
done

# Commit the changes
git commit -m "Added files to $TARGET_DIR"

# Push the changes to the remote repository
git push origin main

echo "All files have been pushed to the '$TARGET_DIR' directory in the repository."

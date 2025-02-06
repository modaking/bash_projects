#!/bin/bash

# Check if at least two arguments are provided (GitHub username and repo name)
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <GitHub Username> <Repository Name> <Folder Path 1> <Folder Path 2> ... <Folder Path N>"
    exit 1
fi

# Construct the GitHub repository URL
REPO_URL="git@github.com:$1/$2.git"
# Assign arguments
GITHUB_USERNAME=$1
REPO_NAME=$2

shift 2  # Remove the first two arguments (GitHub username and repo name), leaving only folder paths


# Clone the repository if it doesn't exist locally
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME" || exit
else
    cd "$REPO_NAME" || exit
    echo "Repository already exists. Pulling latest changes..."
    git pull origin main  # Ensure local repo is up to date
fi

# Loop over the provided folder paths
for FOLDER_PATH in "$@"; do
    # Expand the folder path relative to the home directory
    FOLDER_PATH="$HOME/$FOLDER_PATH"

    # Check if the folder exists
    if [ ! -d "$FOLDER_PATH" ]; then
        echo "Error: Folder '$FOLDER_PATH' does not exist!"
        continue
    fi

    # Get the folder name without the full path
    FOLDER_NAME=$(basename "$FOLDER_PATH")

    # Use rsync to copy while excluding .git directories
    echo "Copying '$FOLDER_NAME' to the repository root..."
    rsync -av --progress --exclude='.git' "$FOLDER_PATH" .

    # Remove any nested .git directories to prevent submodule issues
    find "$FOLDER_NAME" -name ".git" -type d -exec rm -rf {} +

    # Ensure permissions are correct
    chmod -R 755 "$FOLDER_NAME"

    # Check if the folder is empty and add a .gitkeep file if needed
    if [ -z "$(ls -A "$FOLDER_NAME")" ]; then
        touch "$FOLDER_NAME/.gitkeep"
        git add "$FOLDER_NAME/.gitkeep"
        echo "Folder '$FOLDER_NAME' was empty, added .gitkeep to track it."
    else
        echo "Folder '$FOLDER_NAME' and its subfolders added to Git."
    fi

    # Add the folder to Git
    git add "$FOLDER_NAME"
done

# Commit the changes
git commit -m "Added folders and their subfolders to the root directory"

# Push changes to the remote repository
git push origin main

echo "✅ All folders and their subfolders have been pushed successfully!"

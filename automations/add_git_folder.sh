#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GitHub Repository Link> <Folder Name>"
    exit 1
fi

# Assigning arguments
REPO_URL=$1
FOLDER_NAME=$2

# Extract repository name from the URL
REPO_NAME=$(basename "$REPO_URL" .git)

# Clone the repository (if not already cloned)
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME" || exit
else
    cd "$REPO_NAME" || exit
    echo "Repository already exists. Using existing repository."
fi

# Create the folder if it doesn't exist
if [ ! -d "$FOLDER_NAME" ]; then
    echo "Creating folder: $FOLDER_NAME"
    mkdir -p "$FOLDER_NAME"
fi

# Add a placeholder file if the folder is empty
if [ -z "$(ls -A "$FOLDER_NAME")" ]; then
    echo "Adding placeholder file inside $FOLDER_NAME"
    touch "$FOLDER_NAME/.gitkeep"
fi

# Add the folder to Git
git add "$FOLDER_NAME"

# Commit the changes
git commit -m "Added folder: $FOLDER_NAME"

# Push the changes to the remote repository
git push origin main

echo "Folder '$FOLDER_NAME' has been added and pushed successfully!"


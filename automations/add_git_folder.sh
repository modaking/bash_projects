#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <GitHub Repository URL> <Folder Path 1> <Folder Path 2> ... <Folder Path N>"
    exit 1
fi

# Assigning arguments
REPO_URL=$1
shift 1  # Shift the first argument (URL), leaving only the folder paths

# Extract repository name from the URL
REPO_NAME=$(basename "$REPO_URL" .git)

# Clone the repository if it doesn't exist locally
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME" || exit
else
    cd "$REPO_NAME" || exit
    echo "Repository already exists. Using existing repository."
fi

# Loop over the provided folder paths
for FOLDER_PATH in "$@"; do
    # Check if the folder exists
    if [ ! -d "$FOLDER_PATH" ]; then
        echo "Error: Folder '$FOLDER_PATH' does not exist!"
        continue
    fi

    # Create the directory structure in the root of the repository
    RELATIVE_FOLDER_PATH=$(basename "$FOLDER_PATH")
    mkdir -p "$RELATIVE_FOLDER_PATH"  # Create the folder in the root directory

    # Copy the contents of the folder to the created directory in the repo
    cp -r "$FOLDER_PATH"/* "$RELATIVE_FOLDER_PATH/"

    # If the folder is empty, add a .gitkeep file to track the folder
    if [ "$(ls -A "$FOLDER_PATH")" ]; then
        echo "Folder '$FOLDER_PATH' is not empty. Adding files to git."
    else
        touch "$RELATIVE_FOLDER_PATH/.gitkeep"
        git add "$RELATIVE_FOLDER_PATH/.gitkeep"
        echo "Folder '$FOLDER_PATH' was empty, added .gitkeep to track it."
    fi

    # Stage the files for commit
    git add "$RELATIVE_FOLDER_PATH/*"
done

# Commit the changes
git commit -m "Added folders and their contents to the root directory"

# Push the changes to the remote repository
git push origin main

echo "All folders and their contents have been pushed to the root directory in the repository."



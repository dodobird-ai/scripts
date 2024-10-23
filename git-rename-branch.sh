#!/bin/bash
# Function to show usage
show_usage() {
    echo "Usage: $0 <old_branch_name> <new_branch_name>"
    echo "Renames a git branch both locally and remotely"
    echo "Note: This script will not rename the default branch (main/master/prod)"
    exit 1
}
# Function to check if branch exists
branch_exists() {
    git show-ref --verify --quiet "refs/heads/$1"
    return $?
}
# Function to check if working directory is clean
is_working_tree_clean() {
    # Check for staged and unstaged changes
    if ! git diff --quiet --exit-code || \
       ! git diff --cached --quiet --exit-code
    then
        return 1
    fi
    return 0
}
# Function to check if branch is the default branch
is_default_branch() {
    local branch="$1"
    local remote_url
    local repo_path
    # Get the remote URL and extract owner/repo
    remote_url=$(git remote get-url origin)
    repo_path=$(echo "$remote_url" | sed -n 's/.*github.com[:\/]\(.*\)\.git/\1/p')
    # Get default branch from GitHub API
    default_branch=$(curl -s "https://api.github.com/repos/$repo_path" | grep -o '"default_branch": *"[^"]*"' | cut -d'"' -f4)
    [ "$branch" = "$default_branch" ]
    return $?
}
# Check if we have exactly two arguments
if [ $# -ne 2 ]; then
    show_usage
fi
OLD_BRANCH="$1"
NEW_BRANCH="$2"
# Check if working directory is clean
if ! is_working_tree_clean; then
    echo "Error: Working directory is not clean. Please commit or stash your changes first."
    exit 1
fi
# Check if old branch exists
if ! branch_exists "$OLD_BRANCH"; then
    echo "Error: Branch '$OLD_BRANCH' does not exist"
    exit 1
fi
# Check if new branch already exists
if branch_exists "$NEW_BRANCH"; then
    echo "Error: Branch '$NEW_BRANCH' already exists"
    exit 1
fi
# Check if trying to rename default branch
if is_default_branch "$OLD_BRANCH"; then
    echo "Error: Cannot rename default branch. Please change default branch in repository settings first."
    exit 1
fi
# Rename the local branch
echo "Renaming local branch '$OLD_BRANCH' to '$NEW_BRANCH'"
if ! git branch -m "$OLD_BRANCH" "$NEW_BRANCH"; then
    echo "Error: Failed to rename local branch"
    exit 1
fi
# Push the new branch to remote
echo "Pushing new branch '$NEW_BRANCH' to remote"
if ! git push origin -u "$NEW_BRANCH"; then
    echo "Error: Failed to push new branch to remote"
    # Revert local branch rename
    git branch -m "$NEW_BRANCH" "$OLD_BRANCH"
    exit 1
fi
# Delete the old branch from remote
echo "Deleting old branch '$OLD_BRANCH' from remote"
if ! git push origin --delete "$OLD_BRANCH"; then
    echo "Warning: Failed to delete old branch from remote"
    echo "You may need to delete it manually or check if it's protected"
fi
echo "Successfully renamed branch '$OLD_BRANCH' to '$NEW_BRANCH' both locally and remotely"

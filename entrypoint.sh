#!/usr/bin/env bash

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return 2
fi

if [ -z $INPUT_PR_TITLE ]
then
    echo "pr_title must be defined"
    return 2
fi


if [ -z $INPUT_COMMIT_MSG ]
then
    echo "commit_msg must be defined"
    return 2
fi

set -f
IFS=',' eval 'source_folders=($INPUT_SOURCE_FOLDER)'
IFS=',' eval 'destination_folders=($INPUT_DESTINATION_FOLDER)'

source_folders_len=${#source_folders[@]}
destination_folders_len=${#destination_folders[@]}
if [[ $source_folders_len -ne $destination_folders_len ]]; then
  echo "source_folders_len must be equal to destination_folders_len"
  return 2
fi

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master" ]
then
  echo "Destination head branch cannot be 'main' nor 'master'"
  return 2
fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

HOME_DIR=$PWD
CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Creating folder"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cd "$CLONE_DIR"


BRANCH_EXISTS=$(git show-ref "$INPUT_DESTINATION_HEAD_BRANCH" | wc -l)

echo "Checking if branch already exists"
git fetch -a
if [ $BRANCH_EXISTS == 1 ];
then
    git checkout "$INPUT_DESTINATION_HEAD_BRANCH"
else
    git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"
fi

echo "Copying files"
for i in "${!source_folders[@]}"; do
    rsync -a --delete "$HOME_DIR/${source_folders[i]}" "$CLONE_DIR/${destination_folders[i]}/"
done
git add .

if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MSG"

  echo "Pushing git commit"
  git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH

else
  echo "No changes detected"
fi

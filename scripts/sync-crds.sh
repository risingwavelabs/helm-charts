#!/usr/bin/env bash

set -o errexit

# If argument number less than 1, exit.
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 <directory> [branch|tag]"
  exit 1
fi

target_dir=$(realpath "$1")

# If another argument is provided, it will be used as the branch or tag name.
# Otherwise, use the latest release tag.
if [[ $# -eq 1 ]]; then
  branch=$(curl https://api.github.com/repos/risingwavelabs/risingwave-operator/releases/latest 2>/dev/null | jq .tag_name -r)
  # If branch is empty, exit
  if [[ -z "$branch" ]]; then
    echo "Failed to get latest release tag from GitHub"
    exit 1
  fi
else
  branch=$1
fi

# If branch is empty, notify and exit
if [[ -z "$branch" ]]; then
  echo "Empty branch name"
  exit 1
fi

tempdir=$(mktemp -d)
cd "$tempdir" || exit 1
trap 'rm -rf "$tempdir"' EXIT INT TERM HUP

git clone --depth 1 --branch "$branch" --single-branch https://github.com/risingwavelabs/risingwave-operator.git

cd risingwave-operator || exit 1

# Copy each file from config/crds to the corresponding location in the charts/risingwave-operator/crds directory.
# Additionally, add a head and tail to be a helm template.
# shellcheck disable=SC2045
for crd_file in config/crd/bases/*.yaml; do
  target_file=$target_dir/$(basename "$crd_file")
  cp "$crd_file" "$target_file"
done

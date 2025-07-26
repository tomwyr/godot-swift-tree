#!/bin/bash

set -e

# Resolve core lib latest version
core_lib_release_url="https://api.github.com/repos/$CORE_LIB_REPO/releases/latest"

echo "Fetching Godot Node Tree Core latest release information"
core_lib_version=$(curl -s "$core_lib_release_url" | jq -r '.name')

if [ -n "$core_lib_version" ] && [ "$core_lib_version" != "null" ]; then
  echo "Resolved core lib version: $core_lib_version"
  echo "core_lib_version=$core_lib_version" >> $GITHUB_OUTPUT
else
  echo "Failed to resolve core lib latest version." >&2
  exit 1
fi

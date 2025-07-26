#!/bin/bash

set -e

# Convert space-separated strings into arrays
read -ra TARGET_PLATFORMS_ARR <<< "$TARGET_PLATFORMS"
read -ra LIB_EXTENSIONS_ARR <<< "$LIB_EXTENSIONS"

mkdir -p core-libs

for i in ${!TARGET_PLATFORMS_ARR[@]}; do
  platform=${TARGET_PLATFORMS_ARR[$i]}
  lib_ext=${LIB_EXTENSIONS_ARR[$i]}
  file_name="libGodotNodeTreeCore-$CORE_LIB_VERSION-$platform$lib_ext"
  url="https://github.com/$CORE_LIB_REPO/releases/latest/download/$file_name"

  echo "Downloading $file_name from $url"
  dest_path="core-libs/libGodotNodeTreeCore$lib_ext"
  curl -f -L -s -o "$dest_path" "$url"
  
  if [[ ! -f "$dest_path" ]]; then
    echo "Failed to download $dest_path" >&2
    exit 1
  fi
  echo "Saved to $dest_path"
done

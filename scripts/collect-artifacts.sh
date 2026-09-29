#!/usr/bin/env bash

set -euo pipefail

source_path=${1:?usage: collect-artifacts.sh <source-path> <artifact-path> <packages-file> <distribution> <version> <commit> <topology>}
artifact_path=${2:?missing artifact path}
packages_file=${3:?missing packages file}
distribution=${4:?missing distribution}
version=${5:?missing version}
repository_commit=${6:?missing repository commit}
topology=${7:?missing topology}
target_path="$source_path/bin/targets/x86/64"

test -d "$target_path"
test -f "$packages_file"
mkdir -p "$artifact_path/firmware" "$artifact_path/buildinfo"
find "$target_path" -maxdepth 1 -type f -name '*.manifest' -exec cp -t "$artifact_path/buildinfo" {} +
find "$target_path" -maxdepth 1 -type f -name '*.buildinfo' -exec cp -t "$artifact_path/buildinfo" {} +
find "$target_path" -maxdepth 1 -type f ! -name '*.manifest' ! -name '*.buildinfo' -exec cp -t "$artifact_path/firmware" {} +
sha256sum "$artifact_path/firmware"/* > "$artifact_path/firmware/SHA256SUMS"

{
  echo "distribution=$distribution"
  echo "version=$version"
  echo "topology=$topology"
  echo "repository_commit=$repository_commit"
  echo "build_time_utc=$(date --utc +%FT%TZ)"
} > "$artifact_path/buildinfo/build-metadata.txt"
cp "$packages_file" "$artifact_path/buildinfo/"

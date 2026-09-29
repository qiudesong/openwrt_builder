#!/usr/bin/env bash

set -euo pipefail

package_file=${1:?usage: prepare-packages.sh <package-file> [output-file]}
output_file=${2:-selected-packages.txt}
test -f "$package_file"

packages=$(sed 's/[[:space:]]*#.*$//' "$package_file" | awk 'NF' | sort -u | paste -sd ' ' -)
test -n "$packages"
printf '%s\n' "$packages" | tr ' ' '\n' > "$output_file"
printf 'packages=%s\n' "$packages"

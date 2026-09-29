#!/usr/bin/env bash

set -euo pipefail

distribution=${1:?usage: resolve-imagebuilder.sh <distribution> [version]}
version=${2:-}

case "$distribution" in
  openwrt)
    base_url='https://downloads.openwrt.org/releases'
    imagebuilder_prefix='openwrt'
    package_file='openwrt/add_packages'
    ;;
  immortalwrt)
    base_url='https://downloads.immortalwrt.org/releases'
    imagebuilder_prefix='immortalwrt'
    package_file='openwrt/add_packages_immortal'
    ;;
  *)
    echo "Unsupported distribution: $distribution" >&2
    exit 1
    ;;
esac

if [ -z "$version" ]; then
  version=$(curl --fail --location --retry 3 --silent --show-error "$base_url/" \
    | sed -nE 's/.*href="([0-9]+(\.[0-9]+)+)\/.*/\1/p' \
    | sort --version-sort \
    | tail -n 1)
  test -n "$version"
  echo "Resolved latest $distribution release: $version" >&2
fi

if ! [[ "$version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
  echo "Version must be a release version such as 24.10.5" >&2
  exit 1
fi

major_version=${version%%.*}
remaining_version=${version#*.}
minor_version=${remaining_version%%.*}
if (( major_version > 24 || (major_version == 24 && minor_version >= 10) )); then
  extension='tar.zst'
else
  extension='tar.xz'
fi

target_url="$base_url/$version/targets/x86/64"
archive="$imagebuilder_prefix-imagebuilder-$version-x86-64.Linux-x86_64.$extension"
curl --fail --location --retry 3 --remote-name "$target_url/sha256sums"
curl --fail --location --retry 3 --remote-name "$target_url/$archive"
checksum_line=$(awk -v archive="$archive" '$2 == archive || $2 == "*" archive { print }' sha256sums)
test -n "$checksum_line"
printf '%s\n' "$checksum_line" | sha256sum --check --strict >&2

source_path=${archive%.$extension}
case "$extension" in
  tar.zst) tar --use-compress-program=unzstd -xf "$archive" ;;
  tar.xz) tar -Jxf "$archive" ;;
esac
test -d "$source_path"

printf 'source_path=%s\n' "$source_path"
printf 'package_file=%s\n' "$package_file"
printf 'version=%s\n' "$version"

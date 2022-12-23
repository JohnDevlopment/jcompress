#!/bin/bash

declare -r BASENAME=${0##*/}
declare -r ROOTDIR=$(dirname $(realpath $0))

die() {
    echo "$BASENAME: $1" >&2
    exit ${2:-1}
}

bool() {
    local val=${1:?no value}
    expr $val + 1 >/dev/null || die "invalid boolean value: $val"
    test $val -ne 0 && return `true`
    false
}

FILEOPENED=0
SUCCESS=0

cleanup() {
    bool $FILEOPENED && exec 3>&-
    bool $SUCCESS && rm -v install_manifest.txt
}

# cd to the directory of the script
cd $ROOTDIR || exit 1

# install_manifest.txt has to exist
test -f install_manifest.txt || die "missing file: install_manifest.txt"

# Setup pre-exit cleanup method
trap cleanup EXIT

# Open install_manifest.txt for reading
exec 3<install_manifest.txt
FILEOPENED=1

# Read each line
filestoremove=()
while read -u 3 line; do
    if [ -f "$line" ]; then
	test -w "$line" || die "cannot remove $file, permission denied"
	filestoremove+=("$line")
    fi
done
exec 3>&-
FILEOPENED=0

rm -rfv "${filestoremove[@]}"
SUCCESS=1

mandb | tail -n 4

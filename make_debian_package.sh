#!/bin/bash

declare -r PKGNAME=jcompress

cleanup() {
    rm -rf $dir 2> /dev/null
}

clear() {
    rm -rfv packages
    exit
}

usage() {
    echo \
	"usage: make_debian_package.sh [-d]
       make_debian_package.sh clear
       make_debian_package.sh -h|--help"
    exit
}

echo=
if [ "$1" = "-d" ]; then
    shift
    echo=echo
    $echo "debug mode activated" || exit 1
fi

# -h or --help
if [[ $1 =~ -h|--help ]]; then usage; fi

# Clear everything
test "$1" = "clear" && clear

TIMEOUT=30

echo "Enter the version string ($TIMEOUT seconds)"
read -t $TIMEOUT -p '> ' version

if [ -z "$version" ]; then
    echo "no version provided" >&2
    exit 1
fi

# Source files
read -ra SRC < <(cat INSTALL.in | tr "\n" " ")

# Root directory of debian package
dir=packages/${PKGNAME}-$version

# Past this point, any errors will cause the script to exit.
# In that case, all files/directories created herein will be deleted
echo
set -e
trap cleanup ERR

# Create directory structure
$echo mkdir -vp $dir

# Compress source files
$echo ./jcompress --verbose --mode tar.gz ${dir}.tar.gz "${SRC[@]}"

# Copy source files to $dir
$echo cp -vt $dir "${SRC[@]}"

echo "
Finished! Now go into $dir and type this in:
\$ debmake -b ':sh'"

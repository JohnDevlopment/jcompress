#!/bin/bash

cleanup() {
    rm -rf $dir $file packages/$file 2> /dev/null
}

usage() {
    echo \
	"usage: make_debian_package.sh
       make_debian_package.sh -h|--help"
    exit
}

# -h or --help
if [[ $1 =~ -h|--help ]]; then usage; fi

TIMEOUT=30

echo "Enter the version string ($TIMEOUT seconds)"
read -e -t $TIMEOUT -p '> ' version

if [ -z "$version" ]; then
    echo "no version provided" >&2
    exit 1
fi

# Source files
read -ra SRC < <(cat INSTALL.in | tr "\n" " ")

dir=packages/jcompress-$version

# Past this point, any errors will cause the script to exit.
# In that case, all files/directories created herein will be deleted
echo
set -e
trap cleanup ERR

mkdir -p $dir

cp -v -t $dir "${SRC[@]}"

echo "
Finished! Now go into $dir and type this in:
\$ debmake -b ':sh' -s --createorig"

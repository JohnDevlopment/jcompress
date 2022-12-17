#!/bin/bash

cleanup() {
    rm -rf $dir $file packages/$file 2> /dev/null
}

clear() {
    rm -rfv packages
    exit
}

usage() {
    echo \
	"usage: make_debian_package.sh
       make_debian_package.sh clear
       make_debian_package.sh -h|--help"
    exit
}

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

file=jcompress-$version.tar.gz
dir=packages/jcompress-$version

# Past this point, any errors will cause the script to exit.
# In that case, all files/directories created herein will be deleted
echo
set -e
trap cleanup ERR

#./jcompress -m tar.gz $file *

mkdir -p $dir

cp -v -t $dir jcompress jextract jcompress.1

echo "
Finished! Now go into $dir and type this in:
\$ dh_make -s -c gpl3 --createorig"

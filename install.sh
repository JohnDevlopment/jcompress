#!/bin/bash

prefix=/usr/local

declare -r BASENAME=${0##*/}

declare -r ROOTDIR=$(dirname $(realpath $0))

declare -r HELP=$(cat <<EOF
usage: $BASENAME [--prefix PATH]
       $BASENAME -h|--help

Options:
       -h
       --help Print this help message and exit.

       --prefix PATH
              Sets the installation path to PATH. (Default: $prefix)
EOF
	)

die() {
    local msg="$1"
    local code=${2:-1}

    echo "$BASENAME: $msg" >&2
    exit $code
}

# usage: install DIR FILE...
install() {
    local installed=()
    local dir="${1:?no directory}"
    shift
    if [ -z "$1" ]; then
	die "no files to install"
    fi

    local file
    for file; do
	if ! mv -f "$file" "$dir/"; then
	    # Error
	    rm -f "${installed[@]}" >&2
	    die "failed to install $file"
	fi
	installed+=("$dir/${file##*/}")
    done

    printf "%s\n" "${installed[@]}" > "$ROOTDIR/install_manifest.txt"
    echo "installed files:"
    printf "\t%s\n" "${installed[@]}"
    echo "created install_manifest.txt." \
	 "That file is neccessary should you decide to uninstall this with uninstall.sh."
}

# Process commandline
if ! temp=$(getopt -n $BASENAME -o 'h' -l 'help,prefix:' -- "$@"); then
    echo "$HELP" | head -n 2 >&2
    echo "Pass -h to the command for a list of options." >&2
    exit 1
fi
eval set -- "$temp"

while true; do
    case "$1" in
	--help|-h)
	    echo "$HELP"
	    exit
	    ;;
	--prefix)
	    prefix="${2/\~/$HOME}"
	    shift 2
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo "$BASENAME: internal error" >&2
	    exit 1
    esac
done

# Create temporary directory
tmpdir=$(mktemp -d)
trap "rm -rvf $tmpdir" EXIT

# Define source files
binfiles=(jcompress jextract)

# Copy source files into temporary directory
cp -v -t $tmpdir "${binfiles[@]}"

# Substitute version string into the two files.
version=$(cat VERSION)
for file in "${binfiles[@]}"; do
    sed -e "s/\\[VERSION\\]/$version/g" $file > $tmpdir/$file
done

# Create directory if it doesn't exist and check its permissions
mkdir -p $prefix/bin || exit 1

if [ ! -w $prefix/bin ]; then
    echo "$BASENAME: cannot write to $prefix/bin, permission denied" >&2
    exit 1
fi

# Transfer the source files into their respective directories
cd $tmpdir
install $prefix/bin "${binfiles[@]}"

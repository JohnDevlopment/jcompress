#!/bin/bash

# Mutable globals
prefix=/usr/local
dry=0
allinstalled=()
editable=0
binfiles=()
manfiles=()
tmpdir=

# Static globals
declare -r BASENAME=${0##*/}

declare -r ROOTDIR=$(dirname $(realpath $0))

declare -r HELP=$(cat <<EOF
usage: $BASENAME [-dh] [-e|--editable] [--prefix PATH]

Options:
       -h
       --help Print this help message and exit.

       --prefix PATH
              Sets the installation path to PATH. (Default: $prefix).

       -d
       --dry  Do not actually install files; simply show where they
	      would be installed to.

       -e
       --editable
             Do an editable install of files; write symbolic links
	     to the install directories.
EOF
	)

# bool <value>
bool() {
    local val=${1:?no value}
    expr $val + 1 >/dev/null || die "invalid boolean value: $val"
    test $val -ne 0 && return 0
    false
}

# Functions
die() {
    local msg="$1"
    local code=${2:-1}

    echo "$BASENAME: $msg" >&2
    exit $code
}

cleanup() {
    rm -rvf $tmpdir
    finishinstall
}

# usage: fakeinstall DIR FILE...
fakeinstall() {
    local installed=()
    local dir="${1:?no directory}"
    shift
    if [ -z "$1" ]; then
	die "no files to install"
    fi

    local file
    for file; do
	echo "install $dir/$file"
    done
}

initinstall() {
    exec 3>"$ROOTDIR/install_manifest.txt"
    echo "Created install_manifest.txt."
}

finishinstall() {
    if [ -v DONE ]; then return; fi
    exec 3>&-
    echo "Finished writing install_manifest.txt." \
	 "That file is neccessary should you decide to uninstall this with uninstall.sh."
    DONE=1

    if [ -w /usr/lib ]; then
	mandb | tail -n 4
    fi

    echo -e "\nInstalled files: "
    printf "\t%s\n" "${allinstalled[@]}"
}

# usage: install [-p PREFIX] INSTALLDIR FILE...
install() {
    # Parse options
    local prefix
    while getopts :p: OPT; do
	case $OPT in
	    p)
		prefix="$OPTARG"
		;;
	    *)
		die echo "invalid options\nusage: $BASENAME [-p ARG} [--] ARGS..." 2
	esac
    done
    shift $(( OPTIND - 1 ))
    OPTIND=1

    local installed=()
    local installdir="${1:?no directory}"
    shift
    if [ -z "$1" ]; then
	die "no files to install"
    fi

    # Command based on editable option
    local linkcmd="mv -f"
    [ $editable -ne 0 ] && linkcmd="ln -s"

    local file
    for file; do
	if ! $linkcmd "${prefix:+$prefix/}$file" "$installdir/"; then
	    # Error
	    rm -f "${installed[@]}" >&2
	    die "failed to install $file"
	fi
	installed+=("$installdir/${file##*/}")
	allinstalled+=("$installdir/${file##*/}")
    done

    printf "%s\n" "${installed[@]}" >&3
}

# Process commandline
if ! temp=$(getopt -n $BASENAME -o 'hde' -l 'help,dry,prefix:,editable' -- "$@"); then
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
	--dry|-d)
	    dry=1
	    shift
	    ;;
	--editable|-e)
	    editable=1
	    shift
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo "$1"
	    echo "$BASENAME: internal error" >&2
	    exit 1
    esac
done

# Define source files
binfiles=(jcompress jextract)
manfiles=({jcompress,jextract}.1)

# Editable install
if [ $editable -ne 0 ]; then
    initinstall
    install -p $ROOTDIR $prefix/bin "${binfiles[@]}"
    install -p $ROOTDIR $prefix/man/man1 "${manfiles[@]}"
    finishinstall
    exit
fi

# Simulate the install
if bool $dry; then
    tmpdir=$(mktemp -ud)
    echo "Copy files into $tmpdir: ${binfiles[*]} ${manfiles[*]}"
    echo "Install jcompress/jextract version `cat VERSION`"
    echo "create directories:" $prefix/{bin,man/man1}
    fakeinstall $prefix/bin "${binfiles[@]}"
    fakeinstall $prefix/man/man1 "${manfiles[@]}"
    exit
fi

# Create temporary directory
tmpdir=$(mktemp -d)
trap cleanup EXIT

# Copy source files into temporary directory
cp -t $tmpdir "${binfiles[@]}" "${manfiles[@]}"

# Substitute version string into the two files.
version=$(cat VERSION)
for file in "${binfiles[@]}" "${manfiles[@]}"; do
    sed -e "s/\\[VERSION\\]/$version/g" $file > $tmpdir/$file
done

# Create directory if it doesn't exist and check its permissions
if [ ! -w "$prefix" ]; then
    die "you do not have sufficient permissions to write in this directory"
fi

mkdir -p $prefix/{bin,man/man1} || exit 1

if [ ! -w $prefix/bin ]; then
    die "cannot write to $prefix/bin, permission denied"
fi

if [ ! -w $prefix/man/man1 ]; then
    die "cannot write to $prefix/man/man1, permission denied"
fi

# Transfer the source files into their respective directories
cd $tmpdir
initinstall
install $prefix/bin "${binfiles[@]}"
install $prefix/man/man1 "${manfiles[@]}"
finishinstall

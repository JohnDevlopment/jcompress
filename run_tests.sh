#!/bin/bash

# usage: bool <value>
bool() {
    local val=${1:?no value}
    expr $val + 1 >/dev/null || die "invalid boolean value: $val"
    test $val -ne 0 && return `true`
    false
}

declare -r RED='\033[0;31m'
declare -r BLUE='\033[0;34m'
declare -r RESET='\033[0m'

# Get options
while getopts :vh OPT; do
    case $OPT in
	v)
	    export VERBOSE=1
	    ;;
	h)
	    echo "usage: `basename $0` [-vh] [--]"
	    exit
	    ;;
	*)
	    echo "usage: `basename $0` [-vh] [--]"
	    exit 2
    esac
done
shift `expr $OPTIND - 1`
OPTIND=1

echo "Running tests..."

cd tests || exit 1

stderr=()
codes=()
testnames=()

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

# Run each test
for file in test_*.sh
do
    code=1
    testname="${file%.sh}"
    testnames+=("$testname")

    # Run test in modified environment with redirections.
    # Set the exit code on error
    temp=$(env -C .. TESTNAME="$testname" $PWD/$file >$tmpdir/out.log 2>$tmpdir/error.log)
    if [ $? -ne 0 ]; then
	code=0
    fi

    # Save the exit code and stderr
    codes+=($code);# echo $code
    temp=$(cat $tmpdir/error.log)
    if [ -z "$temp" ]; then temp='no error'; fi
    stderr+=("$temp")

    # Print output (no effect if there is none)
    cat $tmpdir/out.log
done

# If any tests have returned false, print out their error output
let i=0
let passed=0
let failed=0
declare -ri LEN=${#codes[@]}

while [ $i -lt $LEN ]
do
    code=${codes[$i]}
    stderr="${stderr[$i]}"
    testname="${testnames[$i]}"

    echo ".......... $testname"

    # If there is error...
    if bool $code; then
	let passed++
    else
	let failed++
	echo -e "$stderr" >&2
    fi

    let i++
done

if [ $failed -ne 1 ]; then
    word1=tests
else
    word1=test
fi

if [ $passed -ne 1 ]; then
    word2=tests
else
    word2=test
fi

test $failed -gt 0 && failed="${RED}$failed"
test $passed -gt 0 && passed="${BLUE}$passed"

echo -e "\n############### $failed $word1 failed${RESET} / $passed $word2 passed${RESET} ###############"

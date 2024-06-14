#!/bin/bash
# Unit test for making sure jcompress extrapolates
# the extension from the archive correctly, and to
# also check if --mode works as it should.
source tests/.common

pwd >&2

for filebase in foo foo-1.0; do
    for fmt in t{gz,bz2,7z} tar.{gz,bz2,7z} zip 7z; do
	res=$(./jcompress debug-check-archive $fmt --awk)
	assert -n "'$res'" --msg "output of: $cmd"
	assert \! -f "$res" --msg "$res should not exist: $cmd"
	vecho -e "cmd: $cmd\n\t$res"
    done
done

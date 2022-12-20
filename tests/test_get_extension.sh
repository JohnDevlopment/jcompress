#!/bin/bash
# Unit test for checking whether jcompress correctly extracts
# the extension from every filename, including those with
# extra dots (e.g., foo-1.0)
source tests/.common

for filebase in foo foo-1.0; do
    for ext in t{gz,bz2,7z} tar.{gz,bz2,7z} zip 7z; do
	NOTRAP=1
	res=$(./jcompress debug-get-extension "$filebase.$ext")
	assert "'$res'" = "'$ext'" --msg "unexpected match, '$res': expected '$ext'"
    done
done

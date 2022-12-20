#!/bin/bash
# Unit test for making sure the option string works as expected.
source tests/.common

# Long options have no trailing comma
opts=$(./jcompress debug-get-long-options)
assert -n "'$opts'"
NOTRAP=1
temp=$(echo "$opts" | grep -E '.*,$')
assert -z "'$temp'" --msg "option string: $temp"

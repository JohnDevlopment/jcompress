#!/bin/bash
# Unit test for the constructed command for the archiver.
source tests/.common

## usage: assert_command_output ARCHIVE EXPECTED
function assert_command_output {
    local archive="$1"
    local expected="$2"

    cmdline=$(./jcompress --dry-run "$archive" ${files[@]})
    assert2 "[ '$cmdline' = '$expected' ]"
}

# This subdirectory is used to for the duration of this test
tmpdir=$(temp-subdir commands)
assert2 "test -d $tmpdir"

# Create the files we'll compress into an archive
(
    dd bs=1M if=/dev/random of=$tmpdir/fileA.bin count=2
    cp $tmpdir/fileA.bin $tmpdir/fileB.bin
    cp $tmpdir/fileA.bin $tmpdir/fileC.bin
) &> /dev/null

files=($tmpdir/file{A,B}.bin)

# Check what commandline jcompress uses to create each type of archive
archives=(archive.{tar.gz,zip,7z})
expected=(
    "tar -cz -f archive.tar.gz ${files[*]}"
    "zip -T archive.zip ${files[*]}"
    "7zr a archive.7z ${files[*]}"
)

for (( i=0; i<3; i++ )); do
    assert_command_output "${archives[$i]}" "${expected[$i]}"
    # echo "Compressing ${archives[$i]}..."
    # ./jcompress ${archives[$i]} ${files[*]} &> /dev/null
done

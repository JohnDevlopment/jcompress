# jcompress

All-in-one compression script.

`jcompress` is a script that wraps around several programs for creating
and manipulating archives. `jextract`, which is included in this, unpacks
archives using those same programs.

The purpose of `jcompress` and `jextract` is to give a convienent way to
do really basic archive operations.

**Note**:
For each program used, not every option is supported by
`jcompress`.

# Features

* Copy or move files into an archive
* Encrypt the archive with a password

## Supported Formats

* 7zip
* zip
* tar.gz
* tar.bz2
* tar.7z

# Install

You can install `jcompress` with `install.sh`. You can run `install.sh -h`
for a list of options.
It installs files to `/usr/local` by default. Use the `--prefix` option to
override it.

Scripts are installed in `$prefix/bin` and manuals in `$prefix/man/man1`.

`install.sh` and `uninstall.sh` call `mandb` after their respective
operations are done. So changes are visible after install.

## Dependencies

In order to work properly, the following programs are needed:

* zip
* tar
* 7z
* gpg (`jcompress` uses this to encrypt tar.gz and tar.bz2 files)

**Suggested**

* pigz (for (un)compressing *.gz files much faster)
* pbzip2 (for (un)compressing *.bz2 files much faster)

# Usage

Both programs accept the `-h` and `--help` options. For now, use those to
to get the list of options. Eventually there will be man pages.

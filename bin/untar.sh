#!/bin/bash

while [ $# -ne 0 ]; do
        tarfile="$1"
        case "${tarfile##*.}" in
                'xz'|'txz')
                        flags="Jtf"
                        ;;
                 'gz'|'tgz')
                         flags="ztf"
                        ;;
                 'bz2')
                         flags="jtf"
                        ;;
                 'zst')
                         flags="-zstd -tf"
                        ;;
                *) echo "Unknown compression algorithm"
                        exit 5
                    ;;
        esac
        shift
done
if [ ! -e "$tarfile" ] ; then
        echo "Can't find $tarfile" >&2
        exit 3
fi

tar -${flags} $tarfile | while read target ; do
        if [ -f "$target" ] ; then
                echo "remove $target"
                rm "$target"
        fi
done


#!/bin/bash

DEF_LOOPDEV=/dev/loop16
DEF_IMG=foo.img
DEF_UTIL=bzcat

while [ $# -ne 0 ]; do
        case "$1" in
        --img)
                        IMAGE="$2"; shift
                        if [ "${IMAGE: -3}" != "bz2" ] ; then
                                DEF_UTIL=
                                if [ "${IMAGE: -2}" == "xz" ] ; then
                                        echo "Switching to xzcat" >&2
                                        DEF_UTIL=xzcat
                                fi
                        fi
                        ;;
        *)
                echo "Not understood: $1" >&2
                        ;;
        esac
        shift
done

if [ -z "$IMAGE" ] ; then
        echo "No image specified." >&2
        exit 2
fi
if [ -z "$DEF_UTIL" ] ; then
        echo "No utility defined for the image $IMAGE" >&2
        exit 3
fi
$DEF_UTIL $IMAGE > "$DEF_IMG"
sudo losetup -P -f --show "$DEF_IMG"
sleep 2
sudo lsblk -o +UUID "$DEF_LOOPDEV"
sudo losetup -d "$DEF_LOOPDEV"
sudo rm "$DEF_IMG"


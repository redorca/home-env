#!/usr/bin/python3
'''
    Run astyle against all files in the current directory
    and below.
'''

import os
import subprocess

CURDIR = "."
ASTYLE_NUTTX = "/home/zglue/bin/astyle-nuttx"
ASTYLE = "/home/zglue/bin/astyle"
# count = "100"
# spot = "init"
# cmd = "find "
# cmd.join(spot)
# # cmd.append( "-type f -name "*.c" -o -name "*.h" "|" )
#
# print("Set amount\n")
# amount = int(count)
# xx = type(amount)
# xx
#
# print("Build command\n")
# cmd.join( "-type f")
# fd = os.popen(cmd, mode='r', buffering=1)
# if not fd:
#     print("failed to open the pipe: %", fd)
# xx = type(fd.read)
# print(";; fd \n", xx)
# xx = type(amount)
# print(":: \n", xx)
#
# os.read(fd.read, 100)
#


def list_files(starting_dir):
    '''
        Walk the subdirs from the current directory and process
        every *.c and *.h files with astyle.
    '''
    for this_dir, dirpath, file_list, in os.walk(starting_dir, topdown=True, followlinks=False):
        if not this_dir:
            this_dir = "."
        print("Dir : " + this_dir)
        subprocess.run(["astyle", "=".join(["--options", ASTYLE_NUTTX]),
                        *[this_dir + "/" + x.strip()
                          for x in file_list if x.endswith(".h") or x.endswith(".c")]])
        print("=================================")


if __name__ == "__main__":
    list_files(CURDIR)

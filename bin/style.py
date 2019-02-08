#!/usr/bin/python3

import os
CURDIR = "."
## count = "100"
## spot = "init"
## cmd = "find "
## cmd.join(spot)
## # cmd.append( "-type f -name "*.c" -o -name "*.h" "|" )
##
## print("Set amount\n")
## amount = int(count)
## xx = type(amount)
## xx
##
## print("Build command\n")
## cmd.join( "-type f")
## fd = os.popen(cmd, mode='r', buffering=1)
## if not fd:
##     print("failed to open the pipe: %", fd)
## xx = type(fd.read)
## print(";; fd \n", xx)
## xx = type(amount)
## print(":: \n", xx)
##
## os.read(fd.read, 100)
##

def list_files(DIR):
    for Dir, Dirpath, File, in os.walk(DIR, topdown=True, followlinks=False):
        print(Dirpath, "/", File, "\n")


list_files(CURDIR)


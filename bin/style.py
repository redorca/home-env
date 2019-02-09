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
        if not Dir:
            Dir = "."
        print("Dir : " + Dir)
        [ print("File: " + Dir + "/" +  x.strip())  for x in File if x.endswith(".h") or x.endswith(".c")]
        print("=================================")

list_files(CURDIR)


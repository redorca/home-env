'''
    Generate a list of files, sift them
    into lists for binary, text, libs,
    man, pdf, html, info, docs, in prep
    for building the files dpkg-build
    needs.
'''

import os
from main import *

TOPDIR="."
PERMS = [ "-", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx", ]

def what_perms(dirpath, lname):
    result = os.stat(os.path.join(dirpath, lname))
    omode = list(oct(result.st_mode)[-4:])
    perms = "".join([PERMS[int(omode[x], base=8)] for x in range(0, 4)])
    # if "5" in omode or "x" in perms:
    #     print("file is exectable: ", name)
    return "".join(omode), perms

def sift_names(topdir):
    for dirpath, direntry, filenames, in os.walk(topdir):
        for afile in filenames:
            perms_oct, perms_alpha = what_perms(dirpath, afile)
            print(" file :: ", afile, "  ",  perms_oct, "  ", perms_alpha)

name_is_main(sift_names(TOPDIR))

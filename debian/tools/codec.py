'''
    Interface to the outside world hiding the specifics of
    the compression or decompression.a

    Oh, and the actual mechanics of codec-ing
'''

'''
    The module "main" provides the function main(func(dkkdkd))
    to turns this file into a callable command
'''
from main import *

import os
import tarfile
import zipfile
import lzma
import bz2
import gzip

'''
    Classes to do lots of stuff
'''

class Codec():
    def __init__(self, filename):
        self.filename = filename
        self.mode = ""
        self.ending = "bz2"
        self.result = "undefined"
        self.suffixes = {"":"w:bz2", "tgz":"r:*", "bz2":"r:*", "gz":"r:*", "gzip":"r:*", "xz":"r:*", "lzma":"r:*"}

    def __set_goals(self):
        print(" ends with? ", self.filename.split(sep="."))
        self.ending = self.filename.split(sep=".")[-1]
        self.mode = self.suffixes[self.ending]

    def codopen(self):
        Codec.__set_goals(self)
        tarfile.open(self.filename, self.mode)

def blah(filename):
    Engage = Codec(filename)
    Engage.codopen()
    print(" file and mode:  ", filename, "  ", Engage.mode)


the_filename = "../../my-keys.tgz"
the_filename = "boohoo"
# blah(the_filename)

main(blah(the_filename))



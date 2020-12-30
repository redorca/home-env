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
        #
        # Default to no ending in case the filename has no suffix
        # If there is a suffix then use it, else stick with the default
        #
        self.ending = ""
        if self.filename.split(sep=".")[-1] != self.filename.split(sep=".")[0]:
                self.ending = self.filename.split(sep=".")[-1]
        self.mode = self.suffixes[self.ending]
        if  self.mode.split(":")[0] == "w":
                self.filename = self.filename + "." + self.mode.split(":")[1]

    def compress(self, filename, mode="bz2"):
        self.mode = mode
        print("compress ", filename, " & mode ", self.mode)

    def decompress(self, filename):
        print("decompress ", filename)

    def codopen(self):
        Codec.__set_goals(self)
        print("codeopen file: ", self.filename, " & mode: ", self.mode)
        foo = tarfile.open(self.filename, self.mode)
        if foo is None:
                print("no file opened.")
        if self.mode.split(".")[0] == "w":
                foo.add("../repo-setup/")
        else:
            foo.extractall()
        foo.close()

def blah(filename):
    Engage = Codec(filename)
    Engage.codopen()
    print(" file and mode:  ", filename, "  ", Engage.mode)


the_filename = "../../my-keys.tgz"
the_filename = "boohoo.bz2"
# blah(the_filename)

main(blah(the_filename))



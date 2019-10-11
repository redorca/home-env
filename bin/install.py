#!/usr/bin/env python3

'''
    Install according to Debian packaging rules. So symlinks go into a
    <pkg>.links file, man files into <pkg>.manpages, etc.

    symlinks     ==> <pkg>.links
    man pages    ==> <pkg>.manpages
    info docs    ==> <pkg>.info
    general docs ==> <pkg>.docs
    created ris  ==> <pkg>.dirs
'''

from classes import SymLinks

PKG = "foo"

BLAH = SymLinks(PKG)
BLAH.add_entry("lib/libfoo.so.0.0.0", "lib/libfoo.so", "lib/libfoo.so.0")
BLAH.add_entry("lib/libfoo.so.0.0.0", "lib/libfoo.so.1")
BLAH.add_entry("lib/libbah.so.0.0.0", "lib/libbah.so.0")
BLAH.dump()
BLAH.flush()

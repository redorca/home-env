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

from classes_de_debiandir import SymLinks

PKG = "foo"

def gen_linksfile(pkg_name, lnk_src, lnk_dst):
    '''
        "install" the symlink requested as an entry into a debian links file.
    '''
    with open(pkg_name + ".links", "a") as f_f:
        f_f.write(lnk_src + "\t" +  lnk_dst)


BLAH = SymLinks(PKG)
BLAH.add_entry("lib/libfoo.so.0.0.0", "lib/libfoo.so")
BLAH.add_entry("lib/libbah.so.0.0.0", "lib/libbah.so.0")
BLAH.dump()
BLAH.flush()

#/usr/bin/python3

'''
    Run after home-env.git is cloned to place managed files in places of use (e.g. .bash_aliases)
'''

import os
import sys
import subprocess as subp
import constants.constants as fra

sys.path.append(".local/bin/home-env/bin")
def symlink(real_file, fake_file, dir_link):
    '''
        Create a symlink between a managed file and a . file in ~
    '''
    re_turn = False
    try:
        os.unlink(fake_file)
    except OSError as ose:
        print("symlink:", ose)
    finally:
        os.symlink(real_file, fake_file, target_is_directory=dir_link)
        re_turn = True
    return re_turn

def process(refiles):
    '''
        Set up all the symlinks
    '''
    for phoo in refiles:
        elements = phoo.split("/")
        original_dir = None
        if len(elements) > 1:
            dirs = elements[0]
            original_dir = relocate(dirs)
        fake = elements[-1]
        real = "/".join([os.getenv("HOME"), fra.LOCAL, phoo])
        if not symlink(real, fake, False):
            print("bad symlink: ", fake)
        if not original_dir is None:
            relocate(original_dir)

def relocate(root):
    '''
        Movce to ROOT
    '''
    before = os.getcwd()
    os.chdir(root)
    return before

def setup_git():
    '''
        "Symlink bin/home-env/.git to .local/.git and checkout files"
    '''
    try:
        symlink(fra.GIT_DIR, ".git", True)
        subp.run(["git", "checkout", "."], check=True)
    except OSError as ose:
        print(ose)

def main():
    '''
        Run the program
    '''
    print("cwd ", relocate('/'.join([os.getenv("HOME") , fra.LOCAL])))
    setup_git()
    print("cwd ", relocate(".."))
    try:
        process(fra.MANAGED_FILES)
    except OSError as ose:
        print(ose)
        return False
    return True

if __name__ == "__main__":
    main()

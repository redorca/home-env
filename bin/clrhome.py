#!/usr/bin/python3

'''
    Clear out everything boo.py placed
'''

import subprocess
import os
import sys
import constants.constants as fra

sys.path.append(".local/bin/home-env/bin")

def main():
    '''
        Duh
    '''
    subprocess.run(["rm", "-rf", fra.LOCAL], check=True)
    subprocess.run(["rm", *fra.MANAGED_FILES], check=True)
    os.makedirs(fra.LOCO_BIN)
    os.chdir(fra.LOCO_BIN)
    subprocess.run(["git", "clone", fra.CLONE_URI], check=True)

if __name__ == "__main__":
    main()

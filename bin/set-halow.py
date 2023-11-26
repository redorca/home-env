#/usr/bin/python3

'''
    Run after home-env.git is cloned to place managed files in places of use (e.g. .bash_aliases)
'''

import os
import sys
import subprocess as subp
import constants.constants as fra

REPOS = [
        "ssh://git@github.com/newracom/nrc7292_sw_pkg.git",
        "ssh://git@github.com/mclendon99/sx-newah.git",
        ]

def clone_repo(Repo):
    '''
        Clone a repo from github
    '''
    try:
        subp.run(["git", "clone", Repo], check=True)
    except OSError as ose:
        print(ose)

def main():
    '''
        Run the program
    '''
    try:
        for repo in REPOS:
            clone_repo(repo)

    except OSError as ose:
        print(ose)
        return False
    return True

if __name__ == "__main__":
    main()

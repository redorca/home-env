#!/bin/env python3

'''
    Wrap calls to apt-get and apt to record changes made to the system. Thinking of
    creating an install rebuild app to recreate the system beyond an install.
'''


import subprocess
import sys


RECORD_FILE = "/home/rick/.local/Documents/txt.replay"
StdRunArgs = { "check":True }


def apt(*pkgs):
    '''
        Run apt obly for searching for the given *pkgs
    '''
    Cmd = [ "sudo", "apt", *pkgs ]
    Result = subprocess.run(Cmd, **StdRunArgs)


def apt_get(action, *pkgs):
    '''
        Run aot-get with action for **pkgs
    '''
    Cmd = [ "sudo", "apt-get", "-y", action, *pkgs ]
    Result = subprocess.run(Cmd, **StdRunArgs)

def fu():
    print("Bar damnit")

def main(myargs):
    '''
        Arg checks and routing.
    '''
    # AllowedActs = [ "remove", "install", "auto-remove", "auto-clean", "search" ]
    RouteArgs = { "remove":apt_get, "install":apt_get, "auto-remove":apt_get, "auto-clean":apt_get, "update":apt_get, "search":apt }
    if not sys.argv[1] in RouteArgs:
        print("No action specified.")
        return False

    print("Will perform", sys.argv[1], *sys.argv[2:])
    RouteArgs[sys.argv[1]](sys.argv[1], *sys.argv[2:])


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv)
    else:
        print("Ok, you're missing a couple of args here.")

    print("All done")

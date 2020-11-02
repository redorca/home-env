#!/bin/env python3

'''
    Wrap calls to apt-get and apt to record changes made to the system. Thinking of
    creating an install rebuild app to recreate the system beyond an install.
'''


import subprocess
import sys


RECORD_FILE = "/home/rick/.local/Documents/txt.replay"
STD_RUN_ARGS = {"check": True, "stderr": subprocess.STDOUT}


def apt(*pkgs):
    '''
        Run apt obly for searching for the given *pkgs
    '''
    cmd = ["sudo", "apt", *pkgs]
    result = subprocess.run(cmd, **STD_RUN_ARGS)
    return result


def apt_get(action, *pkgs):
    '''
        Run aot-get with action for **pkgs
    '''
    cmd = ["sudo", "apt-get", "-y", action, *pkgs]
    return subprocess.run(cmd, **STD_RUN_ARGS)


def main(myargs):
    '''
        Arg checks and routing.
    '''
    # AllowedActs = ["remove", "install", "auto-remove", "auto-clean", "search"]
    route_args = {"remove": apt_get, "install": apt_get, "auto-remove": apt_get,
                  "auto-clean": apt_get, "update": apt_get, "search": apt}
    if not sys.argv[1] in route_args:
        print("No action specified.")
        return False

    print("Will perform", sys.argv[1], *sys.argv[2:])
    try:
        result = route_args[sys.argv[1]](sys.argv[1], *sys.argv[2:])
        print("Result :: ", result.stdout)
        return True
    except subprocess.CalledProcessError as e_e:
        print("Command :: ", e_e.cmd, " returned ", e_e.returncode)
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv)
    else:
        print("Ok, you're missing a couple of args here.")

    print("All done")

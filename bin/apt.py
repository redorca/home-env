#!/bin/env python3

'''
    Wrap calls to apt-get and apt to record changes made to the system. Thinking of
    creating an install rebuild app to recreate the system beyond an install.
'''


import subprocess as subp
import sys
import os

RECORD_FILE = os.environ['HOME'] + "/.local/Documents/txt.replay"
STD_RUN_ARGS = {"check": True, }


def apt(*pkgs):
    '''
        Run apt obly for searching for the given *pkgs
    '''
    cmd = ["sudo", "apt", *pkgs]
    result = subp.run(cmd, **STD_RUN_ARGS)
    return result

def present(*pkgs):
    '''
        See if the set of pkgs is installed.
    '''
    presented = dict()
    presented['found'] = list()
    presented['missing'] = list()

    STD_RUN_ARGS['capture_output'] =  True,
    for pkg in pkgs[1:]:
        try:
            cmds = ['dpkg', '-l', pkg]
            subp.run(cmds, **STD_RUN_ARGS)
            presented['found'].append(pkg)
        except subp.CalledProcessError as cpe:
            presented['missing'].append(pkg)
    found = '\n\t'.join(presented['found'])
    missing = '\n\t'.join(presented['missing'])
    if not len(found) == 0:
        print(f'Found\n\t{found}')
    if not len(missing) == 0:
        print(f'Missing\n\t{missing}')


def verify(dummy, *pkgs):
    verified = dict()
    verified['found'] = list()
    verified['unknown'] = list()

    STD_RUN_ARGS['capture_output'] =  True,
    for pkg in pkgs:
        try:
            cmds = ['apt', 'show', pkg]
            subp.run(cmds, **STD_RUN_ARGS)
            verified['found'].append(pkg)
        except subp.CalledProcessError as cpe:
            verified['unknown'].append(pkg)
    found = '\n\t'.join(verified['found'])
    unknown = '\n\t'.join(verified['unknown'])
    if not len(found) == 0:
        print(f'Found\n\t{found}')
    if not len(unknown) == 0:
        print(f'Missing\n\t{unknown}')

def apt_get(action, *pkgs):
    '''
        Run aot-get with action for **pkgs
    '''
    print(f'pkgs to {action}: {pkgs}')
    with open(RECORD_FILE, mode='ab') as recf:
        STD_RUN_ARGS["stdout"] = recf
        try:
            cmd = ["sudo", "apt-get", "-y", action, *pkgs]
            return subp.run(cmd, **STD_RUN_ARGS)
        except subp.CalledProcessError as cpe:
            verify(action, *pkgs)
            return cpe

def main(myargs):
    '''
        Arg checks and routing.
    '''
    route_args = {"remove": apt_get, "install": apt_get, "auto-remove": apt_get,
                  "auto-clean": apt_get, "update": apt_get, "download": apt_get,
                  "search": apt, 'verify': verify, 'present': present}
    if not myargs[1] in route_args:
        print("No action specified.")
        return False

    result = route_args[myargs[1]](myargs[1], *myargs[2:])
    if not result is None and result.returncode == 0:
        print(f'Result :: {result.stderr}')
        return True

    return False

if __name__ == "__main__":
    rc = 0
    if len(sys.argv) > 1:
        if not main(sys.argv):
            rc = 1
    else:
        print("Ok, you're missing a couple of args here.")
    exit(rc)

#!/bin/env python3

import subprocess
import posix
import sys

pip_keywords = {"check":True, "capture_output":True, "timeout":85}
def freeze():
    '''
        Grab output from "pip3 freeze" into a dictionary
    '''
    PipFreeze = [ "pip3", "freeze" ]
    rout = subprocess.run(PipFreeze, check=True, capture_output=True)
    return [ x for x in dict( x.split('==') for x in [str(x) for x in rout.stdout.split()]).keys()]

def do_run(cmd):
    '''
        Provide a hard coded execution call so the caller has to knonw nothing.
    '''
    return subprocess.run(cmd, **pip_keywords)

def upgrade(modules):
    '''
        run through the list of modules and upgrade each.
    '''
    PipUpgradeCmd = [ "sudo", "python3", "-m", "pip", "install", "--upgrade" ]
    for xxxx in modules:
        print(xxxx.strip())
        try:
            do_run([*PipUpgradeCmd, xxxx.strip()])
        except subprocess.CalledProcessError as e_e:
            print(e_e.stderr)
            return e_e.returncode
        except:
            print(e_e.stderr)

ice = freeze()
upgrade(ice)


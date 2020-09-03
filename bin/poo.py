#!/bin/env python3

'''
    Run through all of the python modules and upgrade them all.
'''

import subprocess
# import posix
# import sys


def freeze():
    '''
        Grab output from "pip3 freeze" into a dictionary
    '''
    pip_freeze = ["pip3", "freeze"]
    rout = subprocess.run(pip_freeze, check=True, capture_output=True)
    new_list = list(rout.stdout.split())
    return [x.split(b'=')[0] for x in new_list]


def do_run(cmd):
    '''
        Provide a hard coded execution call so the caller has to knonw nothing.
    '''
    run_keywords = {"check": True, "capture_output": True, "timeout": 85}
    return subprocess.run(cmd, **run_keywords)


def upgrade(*modules):
    '''
        run through the list of modules and upgrade each.
    '''
    pip_upgrade_cmd = ["sudo", "python3", "-m", "pip", "install", "--upgrade"]
    for xxxx in modules:
        print("xxxx: ", xxxx)
        try:
            result = do_run([*pip_upgrade_cmd, xxxx])
            print(result.stdout.split())
        except subprocess.CalledProcessError as e_e:
            print("CalledProcessError: code ",
                  e_e.returncode, str(e_e.stderr, encoding="utf-8"))
            return False
    return True


ICE = freeze()
print("Frozen @ ", ICE)
upgrade(*ICE)

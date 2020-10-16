#!/usr/bin/env python3

'''
    Called from autostart to make sure the display resolution is set to 2560x1600,
    and two terminal windows are up.
'''

import os
import subprocess
import syslog

XRANDR = "/usr/bin/xrandr"
HOW_MANY_TERMS = 2
TILIX = "/usr/bin/tilix"
GNOME_TERMINAL = "/usr/bin/gnome-terminal"

TASKS = dict()
TASKS[XRANDR] = ['xrandr', '--output', 'Virtual1', '--mode', '2560x1600']
TASKS[TILIX] = ['tilix', '--profile', "Light 0"]
TASKS[GNOME_TERMINAL] = ['gnome-terminal', '--window-with-profile', "big an light"]

MORE_TASKS = dict()
MORE_TASKS[TILIX] = ['tilix', '--profile', "Light 0"]
MORE_TASKS[GNOME_TERMINAL] = ['gnome-terminal', '--window-with-profile', "big an light"]


def is_there(thing):
    '''
        Run os.stat on the path and catch the ValueError exception
        so that a typical return value is available.

        Object is one of a file descriptor, file object, path.
    '''
    try:
        # result = os.stat(thing)
        os.stat(thing)
    except ValueError:
        return False
    except FileNotFoundError:
        return False
    return True


def run_tasks(**da_tasks):
    ''';
        da_tasks a dictionary of file,command tuples where command
        is a list of the command tokens suitable for subprocess.run().
    '''
    syslog.syslog("\nKeys ... " + " ".join(da_tasks.keys()))
    for key in da_tasks.keys():
        if is_there(key):
            syslog.syslog("Run key " + key)
            try:
                subprocess.run(da_tasks[key], check=True)
            except subprocess.CalledProcessError as cpe:
                syslog.syslog("Failed running task " + key + cpe.stderr)
        else:
            syslog.syslog("Can't find " + key)
    return

syslog.openlog()
run_tasks(**TASKS)
run_tasks(**MORE_TASKS)
syslog.closelog()

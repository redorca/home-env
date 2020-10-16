#!/usr/bin/env python3

'''
    Called from autostart to make sure the display resolution is set to 2560x1600
'''

import os
import subprocess

Action = ['xrandr', '--output', 'Virtual1', '--mode', '2560x1600']
# Action = ['xrandr', '--output', 'Virtual1', '--mode', '800x600']

subprocess.run(Action)

PROFILE = "big an light"
Action = ['gnome-terminal', '--window-with-profile', PROFILE]
subprocess.run(Action)
subprocess.run(Action)


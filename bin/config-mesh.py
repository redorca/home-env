'''
    Setup a mesh node given arguments provided.
    ipaddr     ipv4 address for the mesh interface
    iface      The interface to operate on. e.g wlan0, wlan1
    mesh_id    The equivalent to the ssid.
'''

import subprocess as subp
import os
DEF_FLAGS = {'capture_output':True, "check":True}
CMDS = [ "iw dev wlan1 interface add mesh0 type mp mesh_id meshme",
        "iw dev mesh0 set channel 161",
        "ifconfig wlan1 down",
        "ifconfig mesh0 up",
        "ip addr add 192.168.1.200/24 dev mesh0"]

def node_create(channel, mesh_id, ipaddr):
    for index in range(len(CMDS)):
        cmd_args = ['sudo', *CMDS[index].split(' ')]
        try:
            result = subp.run(cmd_args, **DEF_FLAGS)
            print(f'result: {result.stdout}')
        except subp.CalledProcessError as CPE:
            print(f'{CPE.stderr}')
            return

node_create(161, "meshme", "192.168.183.44")


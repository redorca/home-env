'''
    Setup a mesh node given arguments provided.
    ipaddr     ipv4 address for the mesh interface
    iface      The interface to operate on. e.g wlan0, wlan1
    mesh_id    The equivalent to the ssid.
'''

import subprocess as subp
import os
DEF_FLAGS = {'capture_output':True, "check":True}

def node_create(channel, mesh_id, ipaddr):
    '''
    Setup one mesh node on wlanX based on dynamic values.
    '''
    iface="mesh0"
    wlan="wlan1"
    '''
    Fill out the command set with the values passed in. The substition only works
    within the local scope so the commands must be assigned in that scope
    '''
    CMDS = [ f"iw dev {wlan} interface add {iface} type mp mesh_id {mesh_id}",
        f"iw dev {iface} set channel {channel}",
        f"ifconfig {wlan} down",
        f"ifconfig {iface} up",
        f"ip addr add {ipaddr}/24 dev {iface}"]
    for index in range(len(CMDS)):
        cmd_args = ['sudo', *CMDS[index].split(' ')]
        try:
            result = subp.run(cmd_args, **DEF_FLAGS)
            print(f'{result.stdout}')
        except subp.CalledProcessError as CPE:
            print(f"Command::\n\t{' '.join(CPE.cmd)}\nfailed with error: {CPE.returncode}")
            print(f"{CPE.stderr.decode('utf8')}")
            return

node_create(161, "meshme", "192.168.183.44")


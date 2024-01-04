'''
    Setup a mesh node given arguments provided.
    ipaddr     ipv4 address for the mesh interface
    mesh      The interface to operate on. e.g wlan0, wlan1
    mesh_id    The equivalent to the ssid.
'''

import subprocess as subp
import os
DEF_FLAGS = {'capture_output':True, "check":True}

'''
class node():
    def __init__(self):
        self
'''


class mesh():
    def __init__(self, wlan, mesh, mesh_name, channel, ipaddr):
        self.wlan = wlan
        self.mesh = mesh
        self.channel = channel
        self.ipaddr = ipaddr
        self.mesh_name = mesh_name

    def node_create(self):
        '''
        Setup one mesh node on wlanX based on dynamic values.
        Fill out the command set with the values passed in. The substition only works
        within the local scope so the commands must be assigned in that scope
        '''
        CMDS = [ f"iw dev {self.wlan} interface add {self.mesh} type mp mesh_id {self.mesh_name}",
                f"iw dev {self.mesh} set channel {self.channel}",
                f"ifconfig {self.wlan} down",
                f"ifconfig {self.mesh} up",
                f"ip addr add {self.ipaddr}/24 dev {self.mesh}"]
        for index in range(len(CMDS)):
            cmd_args = ['sudo', *CMDS[index].split(' ')]
            try:
                result = subp.run(cmd_args, **DEF_FLAGS)
                print(f'{result.stdout.decode("utf8")}')
            except subp.CalledProcessError as CPE:
                print(f"Command::\n\t{' '.join(CPE.cmd)}\nfailed with error: {CPE.returncode}")
                print(f"{CPE.stderr.decode('utf8')}")
                return

def setup_link_local(interface, iftype):
    '''
    interface is the name of the interface like eth0 or wlan5
    iftype is the type of the interface; i.e. ethernet, wifi, olpc-mesh (olpc:: one laptop per child)
    '''
    CMD = f'nmcli c a ifname {interface} type {iftype} ipv4.method link-local ipv6.method disabled'
    cmd_args = CMD.split(' ')
    # result = subp.run(cmd_args, **DEF_FLAGS)
    print(f'{cmd_args}')

if __name__ == '__main__':
    setup_link_local('mesh0', 'wifi')
    mesh('wlan0', 'mesh0', 'meshme', 161, "192.168.183.44").node_create()


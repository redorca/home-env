'''
    Setup a mesh node given arguments provided.
    ipaddr     ipv4 address for the mesh interface
    mesh      The interface to operate on. e.g wlan0, wlan1
    mesh_id    The equivalent to the ssid.
'''

import subprocess as subp
import os
import json
DEF_FLAGS = {'capture_output':True, "check":True}

'''
class node():
    def __init__(self):
        self
'''

ipv4 = 4
ipv6 = 6
family = {ipv4: 'inet', ipv6: 'inet6'}

class Mesh():
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

    def dump_config(self):
        print(f' wlan:\t\t{self.wlan},\n mesh:\t\t{self.mesh},\n channel:\t{self.channel},\n'
              f' ipaddr:\t{self.ipaddr},\n mesh_name:\t{self.mesh_name}')

class Ipdevices():
    '''
    The set of interfaces that constitute the network subsystem for this host.
    '''
    def __init__(self, ipversion):
        '''
        pull json formatted data from the command: 'ip addr'
        '''
        self.ipversion = ipversion
        self.family = family[ipversion]
        self.json = json.loads(subp.run(['ip', f'-{ipversion}', '-j', 'addr'], capture_output=True, check=True).stdout)

    def device_cnt(self):
        return len(self.json)

    def device_family(self):
        return self.family

    def device_entry(self, ifname):
        return [ entry for entry in self.json if entry['ifname'] == ifname][0]

    def devices(self):
        return [ x['ifname']  for x in self.json ]

    def addresses(self):
        return [ x['addr_info'][0]['local'] for x in self.json ]

    def ipaddress(self, ifname):
        '''
        return a string of the ip.
        '''
        return ''.join([ x['addr_info'][0]['local'] for x in self.json if x['ifname'] == ifname ])

    def set_ipaddr(self, ifname, addr):
        print(f' set the ip address of dev {ifname} to {addr}')

    def setup_link_local(self, ifname, iftype):
        '''
        ifname is the name of the interface like eth0 or wlan5
        iftype is the type of the interface; i.e. ethernet, wifi, olpc-mesh (olpc:: one laptop per child)
        '''
        CMD = f'nmcli c a ifname {ifname} type {iftype} ipv4.method link-local ipv6.method disabled'
        cmd_args = CMD.split(' ')
        result = subp.run(cmd_args, **DEF_FLAGS)
        print(f'{cmd_args}')

class Interface():
    '''
    A particular interface of the network subsystem. Provides access to comms, statistics, config
    '''
    def __init__(self, ifname):
        self.ifname = ifname
        self.interface = [x for x in json.loads(subp.run(['ip', '-j', 'addr'], capture_output=True, check=True).stdout) if x['ifname'] == ifname][0]

    def dump(self):
        return self.interface

if __name__ == '__main__':
    # Ipdevices(ipv4).setup_link_local('mesh0', 'wifi')
    # mesh('wlan0', 'mesh0', 'meshme', 161, "192.168.183.44").node_create()
    Mesh('wlan0', 'mesh0', 'meshme', 161, "192.168.183.44").dump_config()


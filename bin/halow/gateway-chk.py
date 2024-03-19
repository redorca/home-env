'''
    Look for an internet accessible interface and create an /etc/avahi/services/gateway.service symlik
    back to /home/ioaire/etc/avahi/services/gateway.service
'''

import sys
import os
import subprocess as subp
from halow import network

print(f'network families: {network.family[network.ipv4]}')
# stuff = network.InetDevices(network.family[network.ipv4])
stuff = network.InetDevices(network.ipv4)
print(f'stuff {stuff.devices()}')
for iface in stuff.devices():
    # print(f'iiface {iface}')
    addr = stuff.ipaddress(iface)
    # print(f'{addr}')
    sequence = stuff.ipaddress_sequence(addr)
    if sequence[0] == 127:
        '''local host'''
        continue

    if sequence[0] == 169:
        '''link local'''
        continue

    print(f'found a candidate: {iface}')

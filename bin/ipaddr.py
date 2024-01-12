'''
    find the ip address of an interface
'''

from collections import OrderedDict, defaultdict
import argparse as args
import io
import subprocess as subp
import json

def ip_info():
    '''
    pull json formatted data from the command: 'ip addr'
    '''
    return json.loads(subp.run(['ip', '-4', '-j', 'addr'], capture_output=True, check=True).stdout)

def report_ipaddr():
    topo = ip_info()
    print(f'element 1: {topo[1]["ifname"]}')
    for index in topo:
        if index['addr_info'][0]['scope'] == 'global':
            print(f"index: {index['addr_info'][0]['local']}")
            print("=====")

if __name__ == "__main__":
    main()

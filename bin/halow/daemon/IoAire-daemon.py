'''
    A template for a daemon via systemd .service files that provides data, takes commands, checks for gateways 
    provide a remote access to system meta data, primarily.

    May want to add capabilities like OTA updates, location data, location signalling for physically identifying
    the node.
'''

import socket
import json
import os
import subprocess as subp

queue_size = 5
port = 5000

sckt = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sckt.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sckt.bind(('0.0.0.0', port))
sckt.listen(queue_size)

while True:
    c, addr = sckt.accept()
    stuffed = c.recv(100)
    buffer = json.loads(str(stuffed.decode('utf8')))
    print(f'buffer {buffer["name"]}')
    goff = {'name':'foo', 'time':'now'}
    c.send(bytes(json.dumps(goff).encode('utf8')))


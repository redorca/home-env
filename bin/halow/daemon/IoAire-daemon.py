'''
    Run as a daemon vi systemd .service files and provide a remote access to system meta data, primarily.

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
# sckt = socket.socket()
sckt.bind(('',port))
sckt.listen(queue_size)

while True:
    c, addr = sckt.accept()
    stuffed = c.recv(100)
    c.send(b(f'=====  {stuffed}'))


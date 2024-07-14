#!/bin/env python3

import configparser as parser
import platform
import os

RC              =       0
COLOR_CFILE     =      "Documents/colors.host"

host = platform.node()
file_name = '.'.join(['colors', host.lower()])
print(f'Looking for Docuents/{file_name}')
path = '/'.join(['Documents', file_name])
print(f'path to look into {path}')
kolors = parser.ConfigParser()
kolors.read(path)
# print(kolors.sections())
# print(kolors.items('default'))
# print(kolors.items('types'))
# VAL=kolors.get('types', 'ARCHIVE')
# print("Value of ARCHIVE is ", VAL)
# VAL=kolors.get('default', 'GREEN')
# print("which is ", VAL)
# kolors.getint('default,' VAL)

#!/bin/env python3

import configparser as parser
import os

RC              =       0
COLOR_CFILE     =      "Documents/colors.host"

kolors = parser.ConfigParser()
kolors.read(COLOR_CFILE)
print(kolors.sections())
# print(kolors.items('default'))
# print(kolors.items('types'))
VAL=kolors.get('types', 'ARCHIVE')
print("Value of ARCHIVE is ", VAL)
VAL=kolors.get('default', 'GREEN')
print("which is ", VAL)
# kolors.getint('default,' VAL)

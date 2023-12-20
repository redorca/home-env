'''
    Build a service file suitable for systemd to find and run. It goes into /etc/avahi/services
'''

import os
import xml.etree.ElementTree as tree

TOP_TEMPLATE = ["<?xml version='1.0' standalone=\'no\'?><!--*-nxml-*-->",
                "<!DOCTYPE service-group SYSTEM 'avahi-service.dtd'>"]
XML_TEMPLATE = "<service-group>     \
        \
  <name replace-wildcards='yes'>Features on %h</name>       \
        \
  <service protocol='ipv4'>     \
    <type>_http._tcp</type>     \
    <port>5555</port>       \
    <txt-record value-format='text'>key='blah blah blah'</txt-record>       \
</service>      \
</service-group>        \
"
top = tree.fromstring(XML_TEMPLATE)

for child in top:
    if child.tag == 'service':
        blah = tree.SubElement(child, 'host-name')
        blah.text = "flight.local"

tree.indent(top)
line = tree.tostringlist(top)
lines = str(line[0]).split('\\n')
for intro in TOP_TEMPLATE:
    print(f'{intro}')
print('\n')
print(f'0: {lines[0]}')
# for xxx in lines:
#     print(f'{xxx}')
# print(f'{tree.tostring(top)}')
# bush = tree.ElementTree(top)
# bush.write('/tmp/foo.xml')

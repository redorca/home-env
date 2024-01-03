'''
    Build a service file suitable for systemd to find and run. It goes into /etc/avahi/services
'''

import os
import xml.etree.ElementTree as eltree

TOP_TEMPLATE = ["<?xml version='1.0' standalone=\'no\'?><!--*-nxml-*-->",
                "<!DOCTYPE service-group SYSTEM 'avahi-service.dtd'>"]

def build_xmltree(xmlFile):
	top = eltree.Element('service-group')
	name = eltree.SubElement(top, 'name', attrib={"replace-wildcards":'yes'}).text = "Stuff on %h"
	service = eltree.SubElement(top, 'service', attrib={"protocol":'ipv4'})
	eltree.SubElement(service, 'type').text="_http._tcp"
	eltree.SubElement(service, 'port').text='555'
	eltree.SubElement(service, 'host-name').text='flight.local'
	tree = eltree.ElementTree(top)
	eltree.indent(tree)
	tree.write(xmlFile)

def fixup(xmlFile, tmpFile):
    '''
    Post process the output file to include the doc string and xml version declarations
    '''
    with open(xmlFile, 'r') as xml, open(tmpFile, 'w') as tmp:
        tmp.write('\n'.join(TOP_TEMPLATE))
        tmp.write('\n\n\n')
        tmp.write(xml.read())
        tmp.write('\n')

if __name__ == '__main__':
    fixup('/tmp/foo.xml', '/tmp/bar.service')

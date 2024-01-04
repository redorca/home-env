'''
    Build a service file suitable for systemd to find and run. It goes into /etc/avahi/services
'''

import os
import xml.etree.ElementTree as eltree

TOP_TEMPLATE = ["<?xml version='1.0' standalone=\'no\'?><!--*-nxml-*-->",
                "<!DOCTYPE service-group SYSTEM 'avahi-service.dtd'>"]

def build_xmltree(xmlFile, descr, service_type, service_port, hostname):
	top = eltree.Element('service-group')
	name = eltree.SubElement(top, 'name', attrib={"replace-wildcards":'yes'}).text = "Stuff on %h"
	service = eltree.SubElement(top, 'service', attrib={"protocol":'ipv4'})
	eltree.SubElement(service, 'type').text=service_type
	eltree.SubElement(service, 'port').text=service_port
	eltree.SubElement(service, 'host-name').text='.'.join([hostname, 'local'])
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

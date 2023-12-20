'''
    Build a service file suitable for systemd to find and run. It goes into /etc/avahi/services
'''

import os
import xml.etree.ElementTree as eltree

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
GROUP_ELEMENTS = {'service':{'protocol':'ipv4'}, 'name':{'replace-wildcards':'yes', 'text':'stuff on %h'}}
SERVICE_ELEMENTS = { 'host-name':None, 'type':'_http._tcp', 'port':5555}
ROOT_ELEMENT={'root':'service-group', 'children':GROUP_ELEMENTS}
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

fixup('/tmp/foo.xml', '/tmp/bar.service')

'''
    handle services management and creation. Which means using avahi service xml snippets, services.
    Build a service file suitable for avahi to find and run. It goes into /etc/avahi/services
'''

import os
import xml.etree.ElementTree as eltree
import subprocess as subp

DEF_FLAGS = {'capture_output':True, "check":True}
'''
    The preamble for an Avahi service discovery file so the xml
    description of the service becomes valid xml for Avahi to parse.

    Embed newlines, "", to provide formatting as a built-in rather
    than explicitly writing newlines into the file.
'''
TOP_TEMPLATE = ["<?xml version='1.0' standalone=\'no\'?><!--*-nxml-*-->",
                "<!DOCTYPE service-group SYSTEM 'avahi-service.dtd'>",
                "", "", ""]

class Avahi():
    '''
        Manage avahi service discovery & publishing.

        Maybe in the future add full avahi management such as config options
    '''
    def __init__(self):
        self.name = 'avahi'
        self.service_dir = '/etc/avahi/services'

        return

    def build_xmltree(self, tmpFile, descr_text, service_type, service_port, hostname):
	    top = eltree.Element('service-group')
	    name = eltree.SubElement(top, 'name', attrib={"replace-wildcards":'yes'}).text = descr_text
	    service = eltree.SubElement(top, 'service', attrib={"protocol":'ipv4'})
	    eltree.SubElement(service, 'type').text=service_type
	    eltree.SubElement(service, 'port').text=service_port
	    eltree.SubElement(service, 'host-name').text='.'.join([hostname, 'local'])
	    tree = eltree.ElementTree(top)
	    eltree.indent(tree)
	    tree.write(tmpFile)

    def build_service(self, xmlFile, descr_text, service_type, service_port, hostname):
        xmlargs =  [ '/tmp/foo.xml', descr_text, service_type, service_port, hostname ]
        self.build_xmltree(*xmlargs)
        self.fixup('/tmp/foo.xml', xmlFile)
        return xmlFile

    def fixup(self, tmpFile, xmlFile):
        '''
            Post process the output file to include the doc string and xml version declarations
        '''
        with open(xmlFile, 'w') as xml, open(tmpFile, 'r') as tmp:
            xml.write('\n'.join(TOP_TEMPLATE))
            xml.write(tmp.read())
            xml.write('\n')

    def install_service(self, serviceFile):
        args = [ 'sudo', 'cp', '/'.join(['/tmp', serviceFile ]), '/etc/avahi/services' ]
        results = subp.run(args, **DEF_FLAGS)
        print(f' returns {results.returncode} {results.stdout.decode("utf8")}')

    def remove_service(self, serviceFile):
        installedFile = '/'.join([ self.service_dir, serviceFile ])
        args = [ 'sudo', 'rm', installedFile ]
        if not os.access(installedFile, os.F_OK):
            print(f'Nothing to remove, {serviceFile} is not present')
            return
        try:
            results = subp.run(args, **DEF_FLAGS)

        except subp.CalledProcessError as cpe:
            print(f'error {cpe.returncode} {cpe.stderr.decode("utf8")}')


if __name__ == "__main__":
    # build_xmltree('/tmp/foo.xml', 'video', '_http._tcp', '8080', 'IOAire')
    # fixup('/tmp/foo.xml', '/tmp/bar.service')
    # serviceFile = Avahi()
    avahiFile = 'bar.service'
    Avahi().build_service(avahiFile, 'video', '_http._tcp', '8080', 'IOAire')
    Avahi().install_service(avahiFile)
    Avahi().remove_service(avahiFile)


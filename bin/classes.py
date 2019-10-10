
'''
    Class definitions defining formatting for various files used by
    debian packaging; that is, files found in the debian/ dir.
'''

class SymLinks(object):
    '''
        Formatting  used for generating symbolic links in the packaging
        directory (commonly debian/<pkg-name> ) used for staging the build.

        Basic format is <src>\t<dst> where src is the location in the built
        tree (as in tmp/foo/bah/dobo.fy) and dst is the
    '''

    def __init__(self, pkgname):
        self.filename = pkgname + ".links";
        self.data = dict()

    def add_entry(self, real, virt):
        '''
            real is the binary file used as the base for the link
            virt is the link back to the base.
        '''
        if virt in self.data.values():
            print(virt + " already in values.")
            return
        if real in self.data.keys():
            print(real + " already in keys.")
            return
        self.data[real] = virt

    def flush(self):
        '''
            Create the <pkg>.links file from the set of dictionaries.
        '''
        with open(self.filename, 'w') as ff:
            for a, b in self.data.items():
                ff.write(a + "  " + b + "\n")

    def dump(self):
        '''
            reveal contents of data dictionary.
        '''
        for a, b in self.data.items():
            print("\t" +  a + "   " + b)


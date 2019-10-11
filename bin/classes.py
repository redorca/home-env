
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
        '''
            Initialize in the name of pkgname for creating a links file
            suitable for use in building Debian packages using dpkg or
            dh_build.
        '''

        self.filename = pkgname + ".links"
        self.entries = list("")

    def add_entry(self, real, virt):
        '''
            real is the binary file used as the base for the link
            virt is the link back to the base.
        '''

        if not real in self.entries:
            print("initial set for " + real)
            self.entries.append([real, virt])
            print("===" + str(self.entries[0]))
        if  real in self.entries[0]:
            print("append " + virt + " to " +real)

    def flush(self):
        '''
            Create the <pkg>.links file from the set of dictionaries.
        '''

        with open(self.filename, 'w') as f_f:
            for alpha in self.entries:
                f_f.write("\t".join(alpha))
                f_f.write("\n")

    def dump(self):
        '''
            reveal contents of data dictionary.
        '''
        for alpha in self.entries:
            print("\t" +  str(alpha))

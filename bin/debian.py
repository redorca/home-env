'''
    Class definitions defining formatting for various files used by
    debian packaging; that is, files found in the debian/ dir.
'''
import abc

class DebHelperClass(abc.ABC):
    '''
        Formatting  used for generating symbolic links in the packaging
        directory (commonly debian/<pkg-name> ) used for staging the build.

        Basic format is <src>\t<dst> where src is the location in the built
        tree (as in tmp/foo/bah/dobo.fy) and dst is the
    '''

    def __init__(self, pkgname, extension):
        '''
            Initialize in the name of pkgname for creating a links file
            suitable for use in building Debian packages using dpkg or
            dh_build.
        '''

        self.filename = ".".join([pkgname, extension])
        self.entries = list("")

    def add_entry(self, target, *args):
        '''
            Similar to the 'ln' command save the paths are absolute
            with the leading '/' optional.

            target  : The binary file used as the base for the link
            *args   : The set of links to set to target. E.g. libs.
        '''

        links = list(args)
        if not target in self.entries:
            self.entries.append([target, "\t\n\t\t\t".join(links)])

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
            print("\t".join(alpha))

    @abc.abstractmethod
    def validate(self, *args):
        '''
            Context specific method to make sure the files handled conform to
            debhelper's expectations. In particular manpages are placed based
            on parsing the .TH and .DT headers so they better be right else
            those pages are placed who knows where.
        '''

    @abc.abstractmethod
    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''

class SymLinks(DebHelperClass):
    '''
        Special case of a DebianHelperFile that dh_link uses to
        install symlinks and verify/process them.
    '''

    def __init__(self, pkg):
        '''
            Set use specific values then super init.
        '''
        super().__init__(pkg, "links")

    def validate(self, *args):
        '''
            Make sure the paths provided are absolute paths.
        '''

    def keyword(self, *args):
        '''
                Provide a search term to be used for finding files to process.
        '''

        return


class ManPages(DebHelperClass):
    '''
        Debhelper uses dh_installman to place manpages based upon the section
        field in the .TH and .Dt entries.

        This class will  need to realize a validate() method to make sure the
        .Dt and .TH section fields make sense (properly declared).
    '''

    def __init__(self, pkg):
        '''
            Set use specific values then super init.
        '''
        super().__init__(pkg, "manpages")

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class InfoPages(DebHelperClass):
    '''
        boo
    '''

    def __init__(self, pkg):
        '''
            Set use specific values then super init.
        '''
        super().__init__(pkg, "info")

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class Documents(DebHelperClass):
    '''
        boo
    '''

    def __init__(self, pkg):
        '''
            Set use specific values then super init.
        '''
        super().__init__(pkg, "docs")

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class DocBase(DebHelperClass):
    '''
        boo
    '''

    def __init__(self, pkg):
        '''
            Set use specific values then super init.
        '''
        super().__init__(pkg, "doc-base")

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class Systemd(DebHelperClass):
    '''
        boo
    '''

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class SysVInit(DebHelperClass):
    '''
        boo
    '''

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''


class Examples(DebHelperClass):
    '''
        boo
    '''

    def validate(self, *args):
        '''
            Make sure the .TH and .Dt section fields are properly declared.
            Fix them up if possible else raise an error.
        '''
        return

    def keyword(self, *args):
        '''
            return the keyword for use as a search term for this particular class.
        '''

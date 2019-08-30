/usr/bin/env python3

"""
        Manage debian repos from creation to destruction.
        Meant as a replacement for mini-dinstall and
        apt-ftparchive although the end result will
        most likely buid upon mini-dinstall and import
        that as a module.

        Repo organization.

        dists/<Release>/<components>/
              |        | Release    | binary<arch1>/
              |                     |                | Packages
              |                     |                | Packages.gz
              |                     |                | Packages.xz
              |                     |
              |ln -s                | binary<arch2>/
              +-><suite>/                            | Packages
                                                     | Packages.gz
                                                     | Packages.xz

        where Rlease is the name presented to users
        as a whole package set.

        suite are aliases for Release: testing, stable, unstable

        components for debian are main, contrib, non-free all
        of which are present beneath Release.

        binary-arch is the cpu family the software will run on.
        E.g. arm, amd64, powerpc, mips, i386, ...


"""

'''
    Declare all of the command line arguments supported including help
    descriptions.

    To substitute for the install tool so in-line processing may be done
    the install args are reproduced here. At least some subset.

    From Ubuntu Bionic Beaver 18.04.3 LTS

    From install (GNU coreutils) 8.28
         Copyright (C) 2017 Free Software Foundation, Inc.
         License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.

       --backup[=CONTROL]
              make a backup of each existing destination file

       -b     like --backup but does not accept an argument

       -c     (ignored)

       -C, --compare
              compare each pair of source and destination files, and in some cases, do not modify the destination at all

       -d, --directory
              treat all arguments as directory names; create all components of the specified directories

       -D     create all leading components of DEST except the last, or all components of --target-directory, then  copy  SOURCE
              to DEST

       -g, --group=GROUP
              set group ownership, instead of process' current group

       -m, --mode=MODE
              set permission mode (as in chmod), instead of rwxr-xr-x

       -o, --owner=OWNER
              set ownership (super-user only)

       -p, --preserve-timestamps
              apply access/modification times of SOURCE files to corresponding destination files

       -s, --strip
              strip symbol tables

       --strip-program=PROGRAM
              program used to strip binaries

       -S, --suffix=SUFFIX
              override the usual backup suffix

       -t, --target-directory=DIRECTORY
              copy all SOURCE arguments into DIRECTORY

       -T, --no-target-directory
              treat DEST as a normal file

       -v, --verbose
              print the name of each directory as it is created

       --preserve-context
              preserve SELinux security context

       -Z     set SELinux security context of destination file and each created directory to default type

       --context[=CTX]
              like -Z, or if CTX is specified then set the SELinux or SMACK security context to CTX

       --help display this help and exit

       --version
              output version information and exit

       The  backup  suffix is '~', unless set with --suffix or SIMPLE_BACKUP_SUFFIX.  The version control method may be selected
       via the --backup option or through the VERSION_CONTROL environment variable.  Here are the values:


    -d --directory

'''

import click

@click.command
@click.args



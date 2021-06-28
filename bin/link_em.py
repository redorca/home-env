'''
    Symlink to repo files in .local/.??* from ~
'''

import os

begin = "Ready to RUMBLE ..."
done = "That\'s it, baby"

symlink_set = [".vim/", ".vimrc", ".gdbinit", ".gitignore", ".bash_aliases"]

def symlink_it(srch, foo=False):
    print(os.path.abspath(srch), "\n:: ")
    small_srch = srch.split('/')[-1]
    print("file ", srch, "base ", small_srch, "\n")
    if os.path.islink(small_srch) and foo:
        print("Unlinking ", small_srch, "\n")
        os.unlink(small_srch)

    if os.path.lexists(small_srch):
        return False
    return os.symlink(srch, srch.split('/')[-1], target_is_directory =  os.path.isdir(srch))

def assemble_list(xdir):
    for root, dirs, files in os.walk(xdir):
        files.extend([x+'/' for x in dirs])
        return ['/'.join([root,x]) for x in files]


def connect_set():
    target_dir = "/home/george/"
    os.chdir(target_dir)
    print("  ", os.path, "\n")
    for x in assemble_list('.local'):
        if x.split('/')[-1] in symlink_set:
            if not symlink_it(x, foo=True):
                print("No Go for ", x)

if __name__ == "__main__":
    def main():
        connect_set("/home/george/.local")

    main()

'''
    Constant string values used for home environment setup
'''

MANAGED_FILES = [ ".bash_aliases", ".gdbinit", ".gitignore", ".gitconfig", ".vimrc", "Documents/colors.modal.ls", "Documents/colors.template" ]
LOCAL = ".local"
LOCO_BIN = "/".join([LOCAL, "bin"])
CLONE_URI = "ssh://git@github.com/redorca/home-env.git"
GIT_DIR = "bin/home-env/.git"

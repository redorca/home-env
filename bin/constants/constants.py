'''
    Constant string values used for home environment setup
'''

MANAGED_FILES = [ ".bash_aliases", ".gdbinit", ".gitignore", ".gitconfig", ".vimrc", ".vimrc_color", "Documents/colors.modal.ls", "Documents/colors.template", ".ssh/config", ".config/git"]
LOCAL = ".local"
LOCO_BIN = "/".join([LOCAL, "bin"])
CLONE_URI = "ssh://git@github.com/redorca/home-env.git"
GIT_DIR = "bin/home-env/.git"
SAMBA_ENTRY = [ "[]", "path = /home//", "read only = no", "browseable = yes", "guest ok = yes" ]
SAMBA_GLOBAL = [ "guest account = USER" ]
print(SAMBA_ENTRY[1])
RunProcDefaults = { "capture_output":True, "check":True }

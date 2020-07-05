# Configuration file for dircolors, a utility to help you set the
# Configuration file for dircolors, a utility to help you set the
# LS_COLORS environment variable used by GNU ls with the --color option.
# Copyright (C) 1996-2013 Free Software Foundation, Inc.
# Copying and distribution of this file, with or without modification,
# are permitted provided the copyright notice and this notice are preserved.
# The keywords COLOR, OPTIONS, and EIGHTBIT (honored by the
# slackware version of dircolors) are recognized but ignored.
# Below, there should be one TERM entry for each termtype that is colorizable
TERM Eterm
TERM ansi
TERM color-xterm
TERM con132x25
TERM con132x30
TERM con132x43
TERM con132x60
TERM con80x25
TERM con80x28
TERM con80x30
TERM con80x43
TERM con80x50
TERM con80x60
TERM cons25
TERM console
TERM cygwin
TERM dtterm
TERM eterm-color
TERM gnome
TERM gnome-256color
TERM hurd
TERM jfbterm
TERM konsole
TERM kterm
TERM linux
TERM linux-c
TERM mach-color
TERM mlterm
TERM putty
TERM putty-256color
TERM rxvt
TERM rxvt-256color
TERM rxvt-cygwin
TERM rxvt-cygwin-native
TERM rxvt-unicode
TERM rxvt-unicode-256color
TERM rxvt-unicode256
TERM screen
TERM screen-256color
TERM screen-256color-bce
TERM screen-bce
TERM screen-w
TERM screen.Eterm
TERM screen.rxvt
TERM screen.linux
TERM st
TERM st-256color
TERM terminator
TERM tmux*
TERM vt100
TERM xterm
TERM xterm-16color
TERM xterm-256color
TERM xterm-88color
TERM xterm-color
TERM xterm-debian
# Below are the color init strings for the basic file types. A color init
# string consists of one or more of the following numeric codes:
# Attribute codes:
# 00=none 01=bold 02=??? 03=italic 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
#NORMAL 00 # no color code at all
#FILE 00 # regular file: use no color at all
RESET 0 # reset to "normal" color
# XX DIR ${BOLD_ATTR};34 # directory
# XX LINK ${BOLD_ATTR};${CYAN} # symbolic link. (If you set this to 'target' instead of a
DIR ${ITALIC};${DIR} # directory
# LINK 03;${CYAN} # symbolic link. (If you set this to 'target' instead of a
LINK target # symbolic link. (If you set this to 'target' instead of a
 # numerical value, the color is as for the file pointed to.)
MULTIHARDLINK 00 # regular file with more than one link
FIFO ${BG_BLACK};${FIFO} # pipe
SOCK ${BOLD_ATTR};${SOCKET} # socket
DOOR ${BOLD_ATTR};${DOOR} # door
BLK ${BLOCKDRV_BG};${BLOCKDRV};${BOLD_ATTR} # block device driver
CHR ${CHARDRV_BG};${CHARDRV};${BOLD_ATTR} # character device driver
MISSING 00 # ... and the files they point to
ORPHAN ${BG_BLACK};${ORPHAN};${BOLD_ATTR} # symlink to nonexistent file, or non-stat'able file
SETUID ${SETUID};${SETUID_BG} # file that is setuid (u+s)
SETGID ${SETGID};${SETGID_BG} # file that is setgid (g+s)
CAPABILITY ${BLACK};${RED_BG} # file with capability
STICKY_OTHER_WRITABLE ${STICKY_OTHR};${STICKY_OTHR_BG} # dir that is sticky and other-writable (+t,o+w)
OTHER_WRITABLE ${OTHER_WR};${OTHER_WR_BG} # dir that is other-writable (o+w) and not sticky
STICKY ${STICKY};${STICKY_BG} # dir with the sticky bit set (+t) and not other-writable
# This is for files with execute permission:
EXEC ${DEF_ATTR};${EXEC}
# List any file extensions like '.gz' or '.tar' that you would like ls
# to colorize below. Put the extension, a space, and the color init string.
# (and any comments you want to add after a '#')
# If you use DOS-style suffixes, you may want to uncomment the following:
#.cmd ${BOLD_ATTR};32 # executables (bright green)
#.exe ${BOLD_ATTR};${GREEN}
#.com ${BOLD_ATTR};${GREEN}
#.btm ${BOLD_ATTR};${GREEN}
#.bat ${BOLD_ATTR};${GREEN}
# Or if you want to colorize scripts even if they do not have the
# executable bit actually set.
#.sh ${BOLD_ATTR};${GREEN}
#.csh ${BOLD_ATTR};${GREEN}
 # archives or compressed (bright red)
*tar ${BOLD_ATTR};${ARCHIVE}
*tgz ${BOLD_ATTR};${ARCHIVE}
*arc ${BOLD_ATTR};${ARCHIVE}
*arj ${BOLD_ATTR};${ARCHIVE}
*taz ${BOLD_ATTR};${ARCHIVE}
*lha ${BOLD_ATTR};${ARCHIVE}
*lz4 ${BOLD_ATTR};${ARCHIVE}
*lzh ${BOLD_ATTR};${ARCHIVE}
*lzma ${BOLD_ATTR};${ARCHIVE}
*tlz ${BOLD_ATTR};${ARCHIVE}
*txz ${BOLD_ATTR};${ARCHIVE}
*tzo ${BOLD_ATTR};${ARCHIVE}
*t7z ${BOLD_ATTR};${ARCHIVE}
*zip ${BOLD_ATTR};${ARCHIVE}
*z ${BOLD_ATTR};${ARCHIVE}
*Z ${BOLD_ATTR};${ARCHIVE}
*dz ${BOLD_ATTR};${ARCHIVE}
*gz ${BOLD_ATTR};${ARCHIVE}
*lrz ${BOLD_ATTR};${ARCHIVE}
*lz ${BOLD_ATTR};${ARCHIVE}
*lzo ${BOLD_ATTR};${ARCHIVE}
*xz ${BOLD_ATTR};${ARCHIVE}
*zst ${BOLD_ATTR};${ARCHIVE}
*tzst ${BOLD_ATTR};${ARCHIVE}
*bz2 ${BOLD_ATTR};${ARCHIVE}
*bz ${BOLD_ATTR};${ARCHIVE}
*tbz ${BOLD_ATTR};${ARCHIVE}
*tbz2 ${BOLD_ATTR};${ARCHIVE}
*tz ${BOLD_ATTR};${ARCHIVE}
*deb ${BOLD_ATTR};${ARCHIVE}
*rpm ${BOLD_ATTR};${ARCHIVE}
*jar ${BOLD_ATTR};${ARCHIVE}
*war ${BOLD_ATTR};${ARCHIVE}
*ear ${BOLD_ATTR};${ARCHIVE}
*sar ${BOLD_ATTR};${ARCHIVE}
*rar ${BOLD_ATTR};${ARCHIVE}
*alz ${BOLD_ATTR};${ARCHIVE}
*ace ${BOLD_ATTR};${ARCHIVE}
*zoo ${BOLD_ATTR};${ARCHIVE}
*cpio ${BOLD_ATTR};${ARCHIVE}
*7z ${BOLD_ATTR};${ARCHIVE}
*rz ${BOLD_ATTR};${ARCHIVE}
*cab ${BOLD_ATTR};${ARCHIVE}
# image formats
*jpg ${BOLD_ATTR};${IMAGE}
*jpeg ${BOLD_ATTR};${IMAGE}
*mjpg ${BOLD_ATTR};${IMAGE}
*mjpeg ${BOLD_ATTR};${IMAGE}
*gif ${BOLD_ATTR};${IMAGE}
*bmp ${BOLD_ATTR};${IMAGE}
*pbm ${BOLD_ATTR};${IMAGE}
*pgm ${BOLD_ATTR};${IMAGE}
*ppm ${BOLD_ATTR};${IMAGE}
*tga ${BOLD_ATTR};${IMAGE}
*xbm ${BOLD_ATTR};${IMAGE}
*xpm ${BOLD_ATTR};${IMAGE}
*tif ${BOLD_ATTR};${IMAGE}
*tiff ${BOLD_ATTR};${IMAGE}
*png ${BOLD_ATTR};${IMAGE}
*svg ${BOLD_ATTR};${IMAGE}
*svgz ${BOLD_ATTR};${IMAGE}
*mng ${BOLD_ATTR};${IMAGE}
*pcx ${BOLD_ATTR};${VIDEO}
*mov ${BOLD_ATTR};${VIDEO}
*mpg ${BOLD_ATTR};${VIDEO}
*mpeg ${BOLD_ATTR};${VIDEO}
*m2v ${BOLD_ATTR};${VIDEO}
*mkv ${BOLD_ATTR};${VIDEO}
*webm ${BOLD_ATTR};${VIDEO}
*ogm ${BOLD_ATTR};${VIDEO}
*mp4 ${BOLD_ATTR};${VIDEO}
*m4v ${BOLD_ATTR};${VIDEO}
*mp4v ${BOLD_ATTR};${VIDEO}
*vob ${BOLD_ATTR};${VIDEO}
*qt ${BOLD_ATTR};${VIDEO}
*nuv ${BOLD_ATTR};${VIDEO}
*wmv ${BOLD_ATTR};${VIDEO}
*asf ${BOLD_ATTR};${VIDEO}
*rm ${BOLD_ATTR};${VIDEO}
*rmvb ${BOLD_ATTR};${VIDEO}
*flc ${BOLD_ATTR};${VIDEO}
*avi ${BOLD_ATTR};${VIDEO}
*fli ${BOLD_ATTR};${VIDEO}
*flv ${BOLD_ATTR};${VIDEO}
*gl ${BOLD_ATTR};${VIDEO}
*dl ${BOLD_ATTR};${VIDEO}
*xcf ${BOLD_ATTR};${VIDEO}
*xwd ${BOLD_ATTR};${VIDEO}
*yuv ${BOLD_ATTR};${VIDEO}
*cgm ${BOLD_ATTR};${VIDEO}
*emf ${BOLD_ATTR};${VIDEO}
# http://wiki.xiph.org/index.php/MIME_Types_and_File_Extensions
*axv ${BOLD_ATTR};${VIDEO}
*anx ${BOLD_ATTR};${VIDEO}
*ogv ${BOLD_ATTR};${VIDEO}
*ogx ${BOLD_ATTR};${VIDEO}
# audio formats
*aac ${DEF_ATTR};${AUDIO}
*au ${DEF_ATTR};${AUDIO}
*flac ${DEF_ATTR};${AUDIO}
*m4a ${DEF_ATTR};${AUDIO}
*mid ${DEF_ATTR};${AUDIO}
*midi ${DEF_ATTR};${AUDIO}
*mka ${DEF_ATTR};${AUDIO}
*mp3 ${DEF_ATTR};${AUDIO}
*mpc ${DEF_ATTR};${AUDIO}
*ogg ${DEF_ATTR};${AUDIO}
*ra ${DEF_ATTR};${AUDIO}
*wav ${DEF_ATTR};${AUDIO}
# http://wiki.xiph.org/index.php/MIME_Types_and_File_Extensions
*axa ${DEF_ATTR};${AUDIO}
*oga ${DEF_ATTR};${AUDIO}
*opus ${DEF_ATTR};${AUDIO}
*spx ${DEF_ATTR};${AUDIO}
*xspf ${DEF_ATTR};${AUDIO}
*pdf ${BOLD_ATTR};${DOC}
*txt ${BOLD_ATTR};${DOC}
*md  ${BOLD_ATTR};${DOC}
*rst ${BOLD_ATTR};${DOC}
*html ${REVERSE_ATTR};${WWW}

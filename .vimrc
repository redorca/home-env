set tags=./tags
set t_ut=
set expandtab
color murphy

let Host = system("uname -n")

if ! $Host == "zglue-fw"
color pablo
endif

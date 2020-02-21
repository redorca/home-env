

define boo
        !git checkout blue.c
         run --options=$HOME/usr/bin/astyle-nuttx blue.c
end

define goo
        !git checkout blue.h
        run --options=$HOME/usr/bin/astyle-nuttx blue.h
end

define line
        p currentLine
        p formattedLine
end


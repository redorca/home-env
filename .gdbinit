define foo
         run --options=$HOME/usr/bin/astyle-nuttx ./test.c
end
# set args --options=$HOME/usr/bin/astyle-nuttx blue.h

define boo
        !git checkout blue.c
         run --options=$HOME/usr/bin/astyle-nuttx blue.c
end
define blue
        !git checkout blue.*
end

define goo
#       file /home/zglue/bin/astyled
#       run $FILE  --options=/home/zglue/bin/astyle-nuttx ./test.c
#       b adjustComments
        !git checkout blue.h
        run --options=$HOME/usr/bin/astyle-nuttx blue.h

end

define line
        p currentLine
        p formattedLine
end


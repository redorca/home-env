define foo
         run --options=/home/zglue/bin/astyle-nuttx ./test.c
end

define goo
        file /home/zglue/bin/astyled
#       run $FILE  --options=/home/zglue/bin/astyle-nuttx ./test.c
        b adjustComments
        run /home/zglue/bin/astyled --options=/home/zglue/bin/astyle-nuttx ./test.c

end


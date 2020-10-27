###################################################################################################################################
#                                                                                                                                 #
#                                                                                                                                 #
#                                                                                                                                 #
#                                                                                                                                 #
#                                                                                                                                 #
###################################################################################################################################

testprog = "tests.py"
CC	= gcc
RM	= rm -f
CP	= cp -a

BINS = evens
SRCS = ${BINS:%=%.c}
OBJS = ${BINS:%=%.o}


WFLAGS = -Werror -Wall
DFLAGS = -ggdb -gdwarf
OFLAGS = 
CFLAGS = $(OFLAGS) $(WFLAGS) $(DFLAGS)
LDFLAGS =

$(BINS):  %:%.c
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) ${@}.c

$(OBJS): %.o:%.c
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(@:%.o=%.c)


$(SRCS):
	@echo "Write this file $@, sucka!"

clean:
	@$(RM) $(OBJS) $(BINS)

clobber: clean
	@$(RM) core

tests test:
	@./$(testprog)


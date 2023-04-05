'''
    create output suitable for declaring a dictionary out of one file of labels, or text, and one file contaning the numerical values associated with each of those labels.
'''

#
# The file containing a numerical sequence akin to an array index (i.e. 0, 1, 2, 3)
# with each number on its own line.
#
File1 = "/tmp/seq.txt"

#
# This file contains the list of labels or descriptions corresponding to the sequence.
#
File2 = "/tmp/foo.txt"

with open(File1, 'r') as F1, open(File2, 'r') as F2:
    '''
        Read from  each file a line at a time and combine (zip) the two into a tuple.
        The zip function returns a generator rather than the tuple itself so the generator
        must be called too.
    '''
    all= [ x for x in zip([x.rstrip() for x in F2.readlines()], [ int(x.rstrip()) for x in F1.readlines()]) ]

    #
    # Unpack the tuple into a dictionary
    #
    tickerTypes = dict(all)

    #
    # Print out lines suitable as a directory initialization entry. (e.g. "label": value)
    #
    [ print(f'\t"{x}":{tickerTypes[x]},') for x in tickerTypes if x != "..." and x != ".." and x != "." ]

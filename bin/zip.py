'''
    Take two files, one a series of labels, one per line, and a sequence
    of numbers, one per line, and combine the two line by line to produce
    a set of statements suitable for making a dictionary.
'''

File1 = "/tmp/seq.txt"
File2 = "/tmp/foo.txt"

def splode(tup):
    a, b, = tup
    return [b, int(a)]

with open(File1, 'r') as F1, open(File2, 'r') as F2:
    all = [splode(x) for x in zip([ x.rstrip() for x in F1.readlines()], [x.rstrip() for x in F2.readlines()])]
    tickerTypes = dict(all)
    [ print(f'"{x}":{tickerTypes[x]}') for x in tickerTypes ]

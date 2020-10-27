#!/bin/python3
'''
    Assemble a mix of strings and feed them to evens.
'''

import subprocess

test_strings = [ ["When in the course of human events", "course", 6], 
        [ "   When in the course of human events   ", "course", 6],
        [ "                      ", "empty", 0],
        [ "     a  bb ccc dddd  ", 'dddd', 4],
        [ "1 b c d e f ggg h ", 'empty', 0],
        [ "ralpha palpha dalpha breeze", "ralpha", 6]
        ]


for i in range(0, len(test_strings)):
    print("    test string[", i, "]", ":", test_strings[i], ":")
    test = [ './evens', test_strings[i][0] ]
    subprocess.run(test, check=False)
    print("    answer == ", test_strings[i][1], " with ", test_strings[i][2], " letters\n")



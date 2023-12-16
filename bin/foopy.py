from collections import OrderedDict, defaultdict
import argparse as args
import io

Help = defaultdict(lambda: None, {
    'source':"The file to source data from.",
    'output':"The file to store deduplicated source data into.",
    })

def main(in_File, out_file):

    seen = OrderedDict()

    with open(in_File, 'r') as In , open(out_file, 'w') as Out:
        for line in In.readlines():
            seen[line] = seen.get(line, 0) + 1
            if seen[line] == 1:
                Out.writelines(line)
            if seen[line] != 1:
                print(line)

cmdParse = args.ArgumentParser('unique')
cmdParse.add_argument('-I', '--source', help=Help['source'], nargs=1, required=True, action='store')
cmdParse.add_argument('-O', '--output', help=Help['output'], nargs=1, required=True, action='store')

cmdLine = cmdParse.parse_args()
if cmdLine.source is None or cmdLine.output is None:
    print("Please provide to file names for args to this program")
    exit(3)

main(cmdLine.source[0], cmdLine.output[0])

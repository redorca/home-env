'''
    Pick a hostname from a list, read from a file, by subnet ip.

'''

from collections import OrderedDict, defaultdict
import argparse as args
import io
import halow.names

Help = defaultdict(lambda: None, {
    'ip':"The subnet value. E.G. aaa.bbb.ccc.ddd would be ddd"
    })

HOSTNAMES_FILE = "/tmp/hostnames.dictionary"
def main(addr, in_File):

    seen = OrderedDict()
    index = int(addr)
    if index > 255 or index < 1:
        print(f"The ip subnet valuye entered out of bounds: {index} > 255 or < 1")
        return

    with open(in_File, 'r') as In:
           hostnames = In.read().split('\n')
           print(f"{hostnames[index].split(' ')[0]} selected")

cmdParse = args.ArgumentParser('unique')
cmdParse.add_argument('-I', '--ip', help=Help['ip'], nargs=1, required=True, action='store')

cmdLine = cmdParse.parse_args()
if cmdLine.ip is None:
    print("Please provide to file names for args to this program")
    exit(3)

if __name__ == "__main__":
    main(cmdLine.ip[0], HOSTNAMES_FILE)

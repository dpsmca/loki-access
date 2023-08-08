import sys
import os
from pathlib import Path
import csv
import argparse
import traceback
import pprint
import http.cookiejar
import http.cookies
import urllib.request

from config import *

from samplename_parse import get_sample_type


if __name__ == '__main__':
    '''
    Parse a raw filename to get the type of search to be performed.
    Or parse a list of filenames.
    '''
    # Currently supporting --params <param file> interface
    parser = argparse.ArgumentParser(description='Parse RAW filename(s)')
    parser.add_argument('-f', '--file', type=str, required=False, dest="input_list", help="Parse filenames in provided file")
    parser.add_argument('-d', '--debug', required=False, dest="debug", action='store_true',
                        help="Show debug information and intermediate steps")
    parser.add_argument('-v', '--version', action='version', version=f'%(prog)s {LOKI_ACCESS_VERSION}')
    parser.add_argument("filename", type=str, nargs='?', help="Optional file name to test")
    inpArgs = parser.parse_args()
    if len(sys.argv) < 2:
        parser.print_help()
        sys.exit(1)

    debug = inpArgs.debug
    input_filename = inpArgs.filename
    filename_list = inpArgs.input_list
    from_file = False
    if filename_list is not None:
      from_file = True

    if from_file:
      if not Path(filename_list).is_file():
        print("Parameters file does not exist, check path: " + filename_list)
        traceback.print_exc()
        sys.exit(1)
      else:
        with open(filename_list, 'r') as f:
          contents = f.read()
          lines = contents.split('\n')
          for line in lines:
            val = line.strip()
            out = get_sample_type(val)
            print("{}\t{}".format(val, out))
        sys.exit(0)
    else:
      if input_filename is not None:
        out_type = get_sample_type(input_filename)
        print(out_type)
        sys.exit(0)


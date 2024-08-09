#!/usr/bin/python

import sys
import struct

with open(sys.argv[1], "r") as f:
    astr = f.readline()
    line_number=1
    while astr:
        anum=int(astr,16)
        if anum<256:
            sys.stdout.write(struct.pack("B",anum))
        else:
            sys.stderr.write("Error line %d, hexadecimal value is >255 (%d)\n"%(line_number,anum))
        astr = f.readline()
        line_number=line_number+1



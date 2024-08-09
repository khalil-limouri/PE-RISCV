#!/usr/bin/python

import sys

with open(sys.argv[1], "rb") as f:
    word=[]
    byte = f.read(1)
    while byte != b"":
      word.append(ord(byte))
      if len(word)==4:
        print("%02X%02X%02X%02X"%(word[3],word[2],word[1],word[0]))
        word=[]
      byte = f.read(1)
    if len(word)>0:
      while len(word)<4:
        word.append(0)
      print("%02X%02X%02X%02X"%(word[3],word[2],word[1],word[0]))


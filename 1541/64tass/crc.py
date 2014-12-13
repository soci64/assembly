#!/usr/bin/python

import sys

f=open(sys.argv[1],'rb')
a=f.read(16384)
f.close()

sum=c=0
for i in range(8192):
    if i==0x1f01: sum+=c
    else: sum=sum+ord(a[i ^ 0x1f00])+c
    c=0
    if sum>255: c=1
    sum=sum & 255

sum=(sum+c) & 255
a=a[0]+chr((0xbf-sum) & 255)+a[2:]

sum=c=0
for i in range(8192):
    if i==0x1e6: sum+=c
    else: sum=sum+ord(a[(i ^ 0x1f00)+8192])+c
    c=0
    if sum>255: c=1
    sum=sum & 255

sum=(sum+c) & 255
a=a[:0x3ee6]+chr((0xe0-sum) & 255)+a[0x3ee7:]

f=open(sys.argv[2],'wb')
f.write(a)
f.close()

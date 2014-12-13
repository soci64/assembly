#!/usr/bin/python

import sys

f=open(sys.argv[1],'rb')
a=f.read(32768)
f.close()

sum=0
c=0
for i in range(3,32768):
    sum+=ord(a[i])+c
    c=0
    if (sum>255): c=1
    sum=sum & 255

sum=(sum+c+255) & 255
a=a[:2]+chr(255-sum)+a[3:]

sum=0xffff
for i in range(2,32768,2):
    s=(ord(a[i]) << 8) | ord(a[i+1])
    for j in range(16):
        z=s ^ sum
        s=(s << 1) & 65535
        sum=(sum << 1) & 65535
        if (z & 32768): sum^=0x1021

a=chr(sum & 255)+chr(sum >> 8)+a[2:]

f=open(sys.argv[2],'wb')
f.write(a)
f.close()

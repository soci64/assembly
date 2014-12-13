#!/usr/bin/python

import sys

f=open(sys.argv[1],'rb')
a=f.read(32768)
f.close()

sum=0
c=0
for i in range(2,32768):
    if i==16384: sum+=c
    else: sum+=ord(a[i])+c
    c=0
    if (sum>255): c=1
    sum=sum & 255

sum=(sum+c+255) & 255
a=a[:16384]+chr(255-sum)+a[16385:]

sum=0
for i in range(6,32771):
    if i==32768: m2=sum & 255
    elif i==32769: m2=sum >> 8
    elif i==32770: m2=m2
    else: m2=ord(a[i])
    for j in range(8):
        m3=m2 ^ (sum >> 8) ^ (sum >> 11) ^ (sum >> 15) ^ (sum >> 6)
        m2=(m2 >> 1) | ((sum >> 8) & 128)
        sum=((sum << 1) | (m3 & 1)) & 65535

a=chr(sum & 255)+chr(sum >> 8)+a[2:]

f=open(sys.argv[2],'wb')
f.write(a)
f.close()

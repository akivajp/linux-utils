#!/usr/bin/env python
# -*- coding: utf-8 -*-

URL='http://kernel.ubuntu.com/~kernel-ppa/mainline/'
ARCHS=['i386', 'amd64']
FLAVORS=['generic', 'lowlatency']

import argparse
import urllib
import lxml.html
import os
import sys
import subprocess

WGET='wget'
if subprocess.call("which wget > /dev/null", shell=True) != 0:
    sys.stdout.write("[Error] wget is not detected, please install\n")

def GetPackages(tag, outdir, arch, flavor):
    try:
        os.makedirs(outdir)
        print("Making dir: " + outdir)
    except:
        pass
    h = urllib.urlopen("%s/%s" % (URL,tag))
    html = lxml.html.fromstring(h.read())
    anchors = html.xpath('/html/body//a')
    packages = []
    for anchor in anchors:
        href = anchor.attrib['href']
        if href.find('_all.deb') >= 0:
            packages.append(href)
        elif href.find('_%s.deb' % arch) >= 0:
            if not flavor or href.find(flavor) >= 0:
                packages.append(href)
    if not packages:
        sys.stderr.write("[Error] Inappropriate Tag Name: %s\n" % tag)
        sys.exit(1)
    for package in packages:
        cmd="%s -c %s/%s/%s -O %s/%s" % (WGET,URL,tag,package,outdir,package)
        print("[Exec] " + cmd)
        subprocess.call(cmd, shell=True)

def GetLatestTags(count = 3):
    h = urllib.urlopen(URL)
    html = lxml.html.fromstring(h.read())
    anchors = html.xpath('/html/body//a')
    tags = []
    for i in range(1, count+1):
        tag_name = anchors[-i].attrib['href'].strip('/')
        time = anchors[-i].getparent().getnext().text.strip()
        tags.append( {'tag': tag_name, 'time': time} )
#        tags.append( anchors[-i].attrib['href'].strip('/') )
    tags.reverse()
    return tags
#    return anchors[-count:].attrib['href'].strip('/')

def main():
    parser = argparse.ArgumentParser('Get Debian Kernel Packages')
    parser.add_argument('cmd', choices=['get', 'show'], help="Command")
    parser.add_argument('outdir', nargs='?', type=str, help="Output Directory")
    parser.add_argument('--arch', '-a', choices=ARCHS, help='Architecture')
    parser.add_argument('--flavor', '-f', choices=FLAVORS, help='Flavor')
    parser.add_argument('--tag', '-t', type=str, help='Kernel Tag Name')
    args = parser.parse_args()
    if args.cmd == 'show':
        tags = GetLatestTags(3)
        for i, tag in enumerate(tags):
            print("Latest Version [%d]: %s" % (i, tag))
        return
    #print(args)
    if not args.tag:
        tags = GetLatestTags(1)
        print(tags)
        args.tag = tags[0]['tag']
        print("Latest Version: " + args.tag)
    if args.outdir and args.arch:
            GetPackages(args.tag, args.outdir, args.arch, args.flavor)

if __name__ == '__main__':
    main()


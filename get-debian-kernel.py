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

def GetLatestTag():
    h = urllib.urlopen(URL)
    html = lxml.html.fromstring(h.read())
    anchors = html.xpath('/html/body//a')
    return anchors[-1].attrib['href'].strip('/')

def main():
    parser = argparse.ArgumentParser('Get Debian Kernel Packages')
    parser.add_argument('outdir', nargs='?', type=str, help="Output Directory")
    parser.add_argument('--arch', '-a', choices=ARCHS, help='Architecture')
    parser.add_argument('--flavor', '-f', choices=FLAVORS, help='Flavor')
    parser.add_argument('--tag', '-t', type=str, help='Kernel Tag Name')
    args = parser.parse_args()
    #print(args)
    if not args.tag:
        args.tag = GetLatestTag()
        print("Latest Version: " + args.tag)
    if args.outdir and args.arch:
            GetPackages(args.tag, args.outdir, args.arch, args.flavor)

if __name__ == '__main__':
    main()


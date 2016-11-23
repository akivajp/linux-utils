#!/bin/bash

PREFIX=/usr/local
BINDIR=${PREFIX}/bin
LOC=raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")"; pwd)"
source ${SCRIPT_DIR}/common.sh

if [ ! -d ${BINDIR} ]; then
  show_exec sudo mkdir -p ${BINDIR}
fi
show_exec sudo wget ${LOC} -O ${BINDIR}/winetricks && sudo chmod +x ${BINDIR}/winetricks


#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")"; pwd)"
source ${SCRIPT_DIR}/common.sh

BANDLE_DIR=~/.vim/bundle
INSTALL_DIR=${BANDLE_DIR}/neobundle.vim
GIT_NEOBUNDLE=git://github.com/Shougo/neobundle.vim

if [ ! -d ${BANDLE_DIR} ]; then
  show_exec mkdir -p ${BANDLE_DIR}
fi

if [ ! -d ${INSTALL_DIR} ]; then
  show_exec git clone ${GIT_NEOBUNDLE} ${INSTALL_DIR}
fi


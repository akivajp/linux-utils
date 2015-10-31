#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")"; pwd)"
TIME_STAMP=$(date +"%Y/%m/%d %H:%M:%S")

show_exec()
{
  local PANE=""
  local TIME_STAMP=$(date +"%Y/%m/%d %H:%M:%S")
  local PANE=$(tmux display -p "#I.#P" 2> /dev/null)
  if [ "${PANE}" ]; then
    PANE=":${PANE}"
  fi
  if [ ! "${HOST}" ]; then
    HOST=$(hostname)
  fi
  echo "[exec ${TIME_STAMP} on ${HOST}${PANE}] $*" | tee -a ${LOG}
  eval $*

  if [ $? -gt 0 ]
  then
    local RED=31
    local MSG="[error ${TIME_STAMP} on ${HOST}${PANE}]: $*"
    echo -e "\033[${RED}m${MSG}\033[m" | tee -a ${LOG}
    exit 1
  fi
}

proc_args()
{
  ARGS=()
  OPTS=()

  while [ $# -gt 0 ]
  do
    arg=$1
    case $arg in
      --*=* )
        opt=${arg#--}
        name=${opt%=*}
        var=${opt#*=}
        eval "opt_${name}=${var}"
        ;;
      --* )
        name=${arg#--}
        eval "opt_${name}=1"
        ;;
      -* )
        OPTS+=($arg)
        ;;
      * )
        ARGS+=($arg)
        ;;
    esac

    shift
  done
}

abspath()
{
  ABSPATHS=()
  for path in "$@"; do
    ABSPATHS+=(`echo $(cd $(dirname $path) && pwd)/$(basename $path)`)
  done
  echo "${ABSPATHS[@]}"
}

ask_continue()
{
  local testfile=$1
  local REP=""
  if [ "${testfile}" ]; then
    if [ ! -e ${testfile} ]; then
      return
    else
      echo -n "\"${testfile}\" is found. do you want to continue? [y/n]: "
    fi
  else
    echo -n "do you want to continue? [y/n]: "
  fi
  while [ 1 ]; do
    read REP
    case $REP in
      y*|Y*) break ;;
      n*|N*) exit ;;
      *) echo -n "type y or n: " ;;
    esac
  done
}

proc_args $*

THREADS=1
if [ $opt_threads ]; then
  THREADS=${opt_threads}
fi


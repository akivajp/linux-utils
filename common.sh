#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")"; pwd)"
TIME_STAMP=$(date +"%Y/%m/%d %H:%M:%S")

get_stamp()
{
  local FILE=$1
  local PANE=""
  local TSTAMP=$(date +"%Y/%m/%d %H:%M:%S")
  local H=${HOST}
  if [ "${HOSTNAME}" ]; then
    H=${HOSTNAME}
  fi
  local TPANE=$(tmux display -p "#I.#P" 2> /dev/null)
  if [ "${TPANE}" ]; then
    PANE=":${TPANE}"
  fi
  echo "${TSTAMP} on ${H}${PANE}"
}
export -f get_stamp

show_exec()
{
  local STAMP=$(get_stamp)
  echo "[exec ${STAMP}] $*" | tee -a ${LOG}
  "$@"

  if [ $? -gt 0 ]
  then
    local red=31
    local msg="[error ${STAMP}]: $*"
    echo -e "\033[${red}m${msg}\033[m" | tee -a ${LOG}
    exit 1
  fi
}
export -f show_exec

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


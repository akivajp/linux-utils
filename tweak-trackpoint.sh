#!/bin/bash

DEVICE="PS/2 Generic Mouse"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")"; pwd)"
source ${SCRIPT_DIR}/common.sh

usage() {
  echo "usage: $0 command ..."
  echo "  commands: disable-scroll enable-scroll status"
}

disable_scroll() {
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation" 0
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Button" 4
  #show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Timeout" 200
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Axes" 0 0 4 5
}

enable_scroll() {
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation" 1
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Button" 2
  #show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Timeout" 200
  show_exec xinput set-prop "${DEVICE}" "Evdev Wheel Emulation Axes" 6 7 4 5
}

CMD=${ARGS[0]}
echo "command: ${CMD}"

if [ "${CMD}" == "status" ]; then
  show_exec xinput list-props "${DEVICE}"
elif [ "${CMD}" == "enable" ]; then
  enable_scroll
elif [ "${CMD}" == "enable-scroll" ]; then
  enable_scroll
elif [ "${CMD}" == "disable" ]; then
  disable_scroll
elif [ "${CMD}" == "disable-scroll" ]; then
  disable_scroll
else
  usage
  exit 1
fi


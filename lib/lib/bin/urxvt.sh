#!/bin/dash
export SHELL=/bin/zsh
urxvtc $@
if [ $? -eq 2 ]; then
  urxvtd -q -o -f
  urxvtc $@
fi
#!/bin/bash
if [ "$1" ]; then
  cat /dev/random|xxd -c $1 |awk -F '  ' '{print $2}'
else
  cat /dev/random|xxd -c 145 |awk -F '  ' '{print $2}'
fi

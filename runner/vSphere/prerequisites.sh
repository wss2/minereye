#!/bin/bash

declare -a CmdList=(python3 kubectl helm helmfile jq)
echo "Check prerequisites software"
MIS="false"
for cmd in "${CmdList[@]}"; do
  printf '%-10s' "$cmd"
  if hash "$cmd" 2>/dev/null; then
    echo OK
  else
    echo missing please install this command
    MIS="true"
  fi
done

if "$MIS" = "true" ; then
    echo "you need to install those all the prerequisites"
    echo "run ./pre.sh"
    exit 1
else
    echo "All prerequisites software are installed"
fi



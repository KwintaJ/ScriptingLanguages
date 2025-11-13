#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Problem SHELL04
# File SERVER
set -e


###########################################################
# reakca serwera na ?/INC

COUNTER_FILE="./counter.txt"

read -r line || exit 0

case "$line" in
    "?")
        if [ -f "$COUNTER_FILE" ]; then
            cat "$COUNTER_FILE"
        else
            echo "0"
        fi
        ;;
    "INC")
        if [ -f "$COUNTER_FILE" ]; then
            COUNTER=$(cat "$COUNTER_FILE")
        else
            COUNTER=0
        fi

        (( COUNTER += 1 ))
        echo "$COUNTER" > "$COUNTER_FILE"
        ;;
esac

#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Problem SHELL04
# File CLIENT
set -e


###########################################################
# zmienne klienta

SERVER_PORT=6789
PORT_FILE="./.port"
MSG=""

###########################################################
# zmiana portu

if [ -f "$PORT_FILE" ] ; then
    IFS= read -r SERVER_PORT < "$PORT_FILE"
fi

###########################################################
# sprawdzenie argumentow
if (( "$#" < 1 )) ; then
    echo "Use client ?/INC/test1"
    exit 1
fi

MSG=$1

###########################################################
# wyslanie wiadomosci do serwera

case "$MSG" in
    "?")
        RSP=$( echo "?" | nc localhost $SERVER_PORT )
        echo $RSP
        ;;
    "INC")
        echo "INC" | nc localhost $SERVER_PORT
        ;;
    "test1")
        RSP=$( echo "?" | nc localhost $SERVER_PORT )
        echo $RSP
        echo "INC" | nc localhost $SERVER_PORT
        RSP=$( echo "?" | nc localhost $SERVER_PORT )
        echo $RSP
        echo "INC" | nc localhost $SERVER_PORT
        RSP=$( echo "?" | nc localhost $SERVER_PORT )
        echo $RSP
        ;;
esac
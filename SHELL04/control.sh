#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Problem SHELL04
# File CONTROLLER
set -e



###########################################################
# zmienne globalne

SERVER_PORT=6789
SERVER_COMMAND=""
CONF_FILE="~/.config/server.conf"

###########################################################
# wczytanie pliku konfiguracyjnego

if [ -f "$CONF_FILE" ]; then
    IFS= read -r SERVER_PORT < "$CONF_FILE"
fi

###########################################################
# sprawdzenie argumentow

if (( "$#" < 1 )) ; then
    echo "Use command start/status/stop/restart"
    exit 1
fi

SERVER_COMMAND=$1

if (( "$#" == "2" )) ; then
    SERVER_PORT=$2
fi

echo "$SERVER_COMMAND, $SERVER_PORT"

###########################################################
# wykonanie polecenia

case "$SERVER_COMMAND" in
        start)
            ./server.sh $SERVER_PORT
            ;;
        status)
            
            ;;
        stop)

            ;;
        restart)

            ;;
esac

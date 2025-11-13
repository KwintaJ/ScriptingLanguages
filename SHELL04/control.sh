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
PORT_FILE="./.port"
CONF_FILE="~/.config/server.conf"
PID_FILE="./server.pid"
COUNTER_FILE="./counter.txt"

###########################################################
# wczytanie pliku konfiguracyjnego

if [ -f "$CONF_FILE" ] ; then
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

echo "$SERVER_PORT" > "$PORT_FILE"

###########################################################
# wykonanie polecenia

case "$SERVER_COMMAND" in
        start)
            if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1 ; then
                # serwer juz dziala
                exit 2
            fi

            # sprawdzenie czy port jest dostępny
            if lsof -i ":$SERVER_PORT" 2>/dev/null ; then
                echo "Port $SERVER_PORT is unavailable"
                exit 3
            fi

            # start serwera
            socat TCP-LISTEN:$SERVER_PORT,reuseaddr,fork SYSTEM:"bash ./server.sh" 2>/dev/null &
            echo $! > "$PID_FILE"
            ;;
        status)
            if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1 ; then
                cat "$PID_FILE"
            fi
            ;;
        stop)
            if [ -f "$PID_FILE" ] ; then
                PID=$(cat "$PID_FILE")
                if ps -p "$PID" > /dev/null 2>&1; then
                    kill "$PID" 2>/dev/null || true
                fi
                rm -f "$PID_FILE"
            fi

            if [ -f "$PORT_FILE" ] ; then
                rm -f "$PORT_FILE"
            fi
            ;;
        restart)
            "$0" stop
            sleep 0.2
            "$0" start "$SERVER_PORT"
            ;;
esac

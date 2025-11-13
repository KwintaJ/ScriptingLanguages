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
# wyslanie wiadomosci do serwera
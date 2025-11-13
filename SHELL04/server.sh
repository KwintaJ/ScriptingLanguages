#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Problem SHELL04
# File SERVER
set -e



########################################################################
# start serwera

SERVER_PORT=$1

echo "Hello"

socat TCP-LISTEN:$SERVER_PORT,reuseaddr,fork STDOUT
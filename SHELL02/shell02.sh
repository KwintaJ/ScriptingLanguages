#!/bin/bash 
# Jan Kwinta
#
# 16.10.2025
#
# Zadanie SHELL02
set -e

while getopts "abcde" flag; do
    case ${flag} in
        a) echo "-a present"
        ;;
        b) echo "-b present"
        ;;
        c) echo "-c present"
        ;;
        d) echo "-d present"
        ;;
        e) echo "-e present"
        ;;
    esac
done

shift $(($OPTIND - 1))
echo "Arguments are: $*"

#!/bin/bash 
# Jan Kwinta
#
# 06.10.2025
#
# Problem SHELL01
set -e

# granice przedzialu indeksow tabelki
a=1
b=1

# sprawdzanie istnienia i sensownosci argumentow
if (( "$#" < 1 )) ; then
    exit 1
elif (( "$#" == "1" )) ; then
    b=$1
elif (( "$1" > "$2" )) ; then
    exit 2
else
    a=$1; b=$2
fi

# drukowanie tabelki
# pierwszy wiersz tabeli - liczby od a do b
printf "    "
for i in $(seq $a $b) ; do
    printf "%4d" "$i"
done
echo ""

# pozostala czesc tabeli - indeksy + mnozenie
for i in $(seq $a $b) ; do
    printf "%4d" "$i"
    for j in $(seq $a $b) ; do
        printf "%4d" "$((i * j))"
    done
    echo ""
done

#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Tester do problemu SHELL03
set -e

for (( i=1 ; i < 6 ; i++ )) ; do
    for (( j=1 ; j < 6 ; j++ )) ; do
        for (( k=1 ; k < 6 ; k++ )) ; do
            for (( l=1 ; l < 6 ; l++ )) ; do
                mkdir -p DIR0$i/DIR1$j/DIR2$k/DIR3$l
                touch DIR0$i/DIR1$j/DIR2$k/DIR3$l/$i$j$k$l.txt
                echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$j$k" > DIR0$i/DIR1$j/DIR2$k/DIR3$l/$i$j$k$l.txt
            done
            touch DIR0$i/DIR1$j/DIR2$k/$i$j$k.txt
            echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$i$j" > DIR0$i/DIR1$j/DIR2$k/$i$j$k.txt
        done
        touch DIR0$i/DIR1$j/$i$j.txt
        echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$i" > DIR0$i/DIR1$j/$i$j.txt
    done
    touch DIR0$i/$i.txt
    echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa123" > DIR0$i/$i.txt
done

echo "first du"
du -d 0 .
echo ""

echo "--max-depth=3"
time ../shell03.sh --max-depth=3 .
du -d 0 .
echo ""

echo "--max-depth=infinity"
time ../shell03.sh .
du -d 0 .
echo ""

echo "--max-depth=3 --replace-with-hardlinks"
time ../shell03.sh --max-depth=3 --replace-with-hardlinks .
du -d 0 .
echo ""

echo "--max-depth=infinity --replace-with-hardlinks"
time ../shell03.sh --replace-with-hardlinks .
du -d 0 .
echo ""

rm -rf DIR*
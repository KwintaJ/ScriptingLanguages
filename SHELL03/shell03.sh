#!/bin/bash 
# Jan Kwinta
#
# 20.10.2025
#
# Problem SHELL03
set -e

# parsowanie opcji
SHORT_OPTS=""
LONG_OPTS="replace-with-hardlinks help max-depth: hash-algo:"

PARSED=$(getopt --options="$SHORT_OPTS" --longoptions="$LONG_OPTS" --name "$0" -- "$@") || exit 2
eval set -- "$PARSED"

HELP=0
MAX_DEPTH=1
HASH_ALGO="md5"
HARDLINKS_REPLACE=0
DIR=""

# przetwarzanie flag opcji
while true; do
    case "$1" in
        --help)
            HELP=1
            shift
            ;;
        --max-depth)
            MAX_DEPTH=$2
            shift 2
            ;;
        --hash-algo)            
            HASH_ALGO=$2
            shift 2
            ;;
        --replace-with-hardlinks)
            HARDLINKS_REPLACE=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: $1"
            exit 99
            ;;
  esac
done

# wydrukowanie help - opis uzycia programu
if (( $HELP == 1 )) ; then
    echo "--------File duplicate remover--------"
    echo ""
    echo "    Use this script to search a directory for"
    echo "    file duplicates and remove any if found."
    echo ""
    echo ""
    echo " Usage:"
    echo " ./shell03.sh [--replace-with-hardlinks][--max-depth=N][--hash-algo=X] DIRNAME"
    echo ""
    echo "    replace-with-hardlinks: Replaces duplicates with hardlinks instead of removing."
    echo "    max-depth: Searches in subdirectories up to N directories deep."
    echo "    hash-algo: Uses specific hash function to compare files. Default is md5."
    echo ""
    echo ""
    exit 1
fi

# sprawdzamy czy zostal podany folder
if (( $# < 1 )) ; then
    echo "target directory was not set"
    exit 2
else
    DIR=$1
fi

if [[ "${DIR: -1}" != "/" ]] ; then
    DIR="$DIR"/
fi

if [[ ! -d "$DIR" ]] ; then
    echo "directory $DIR does not exist"
    exit 3
fi

DIR_LIST=$( ls $DIR )


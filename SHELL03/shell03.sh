#!/bin/bash 
# Jan Kwinta
#
# 20.10.2025
#
# Problem SHELL03
set -e

DIR_LIST=()

function addDirectoryContents {
    local currentDir=$1
    local currentDepth=$2
	
    # ls
    local currentList=()
    currentList+=$(ls -p $currentDir)
    # ls dodajemy do listy
    for thing in $currentList ; do
    	DIR_LIST+="$currentDir$thing "
    done
    
    # konczymy jesli jestesmy na najnizszym poziomie
    if (( currentDepth <= 1 )) ; then
    	return 0
    fi
    
    # w przeciwnym wypadku dodajemy rekurencyjnie rzeczy w podfolderach
    for thing in $currentList ; do
    	if [[ -d "$currentDir$thing" ]] ; then
            addDirectoryContents "$currentDir$thing" $(( currentDepth - 1 ))
        fi
	done
}

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

# sprawdzam czy zostal podany folder
if (( $# < 1 )) ; then
    echo "target directory was not set"
    exit 2
else
    DIR=$1
fi

# dodaje / na koncu nazwy folderu
if [[ ${DIR: -1} != "/" ]] ; then
    DIR="$DIR"/
fi

# sprawdzam czy podany folder istnieje
if [[ ! -d "$DIR" ]] ; then
    echo "$DIR does not exist or is not a directory"
    exit 3
fi

# dodajemy do DIR_LIST wszystko w folderze 
# oraz podfolderach do MAX_DEPTH poziomow w dol
addDirectoryContents $DIR $MAX_DEPTH

# lista wszystkich plikow do przetworzenia
FILE_LIST=()
# wpisanie do listy tylko plikow
for thing in $DIR_LIST ; do
    if [[ ! -d "$thing" ]] ; then
    	FILE_LIST+="$thing "
    fi
done

for file in $FILE_LIST ; do
    echo $file
done

echo ""
echo ""

for file in $FILE_LIST; do
    echo "$(stat -c%s "$file") $file"
done | sort -n

#!/bin/bash 
# Jan Kwinta
#
# 24.10.2025
#
# Problem SHELL03
set -e



########################################################################
# ZMIENNE GLOBALNE

# dozwolone flagi opcji
SHORT_OPTS=""
LONG_OPTS="replace-with-hardlinks help max-depth: hash-algo:"
# opcje 
HELP=0
MAX_DEPTH=1
HASH_ALGO="md5"
HARDLINKS_REPLACE=0
# jedyny argument - docelowy folder
DIR=""
# lista z zawartoscia folderu DIR
FILE_LIST=()
# zmienne operacyjne
DUPLICATE_LIST=()
# zmienne do raportu
processedFiles=0
duplicatesFound=0
filesRemoved=0



########################################################################
# FUNKCJE

# wypisuje help - opis uzycia skryptu
printHelp () {
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
}

# funkcja przeszukuje drzewo folderow, tworzy liste plikow
# posortowana wzgledem rozmiaru
findAndSortFiles () {
    # wpisanie do FILE_LIST tylko plikow z podanego folderu
    # oraz poddfolderow do MAX_DEPTH poziomow w dol
    
    # stworzenie pliku tymczasowego i wpisanie do niego 
    # wyniku polecenia find
    tempFile=$(mktemp ./tmp01XXXXXX)  
    find .  -maxdepth 3 -type f -print0 | xargs -0 stat -f '%z %N' | sort -n | awk '{ $1=""; sub(/^ /, ""); print }' > $tempFile

    # wypelnienie FILE_LIST
    while IFS= read -r file; do
        # pomiń plik tymczasowy
        [[ "$file" == "$tempFile" ]] && continue

        FILE_LIST+=("$file")
        (( processedFiles += 1 ))
    done < "$tempFile"
    
    # usuniecie pliku tymczasowego
    rm $tempFile
}

# funkcja iteruje sie po FILE_LIST szukajac plikow o
# takiej samej wielkosci i wywoluje compareFiles
removeDuplicates () {
    local currentSize=-1
    local currentDuplicates=0

    for (( k=0 ; k < ${#FILE_LIST[@]} ; k++ )) ; do
        local fileSize=$(stat -f%z "${FILE_LIST[k]}")
        
        if [[ $fileSize > $currentSize ]] ; then
            if [[ $currentDuplicates > 1 ]] ; then
                compareFiles
            fi
            DUPLICATE_LIST=()
            currentDuplicates=0
            currentSize=$fileSize
        fi
        DUPLICATE_LIST+=("${FILE_LIST[k]}")
        (( currentDuplicates += 1 ))
    done
}

# funkcja porownuje $1 plikow z DUPLICATE_LIST
# oraz usuwa/podmienia duplikaty 
compareFiles () {
    local alreadyRemoved=()
    for (( i=0 ; i < ${#DUPLICATE_LIST[@]} ; i++ )) ; do
        alreadyRemoved[i]=0
    done

    for (( i=0 ; i < ${#DUPLICATE_LIST[@]} ; i++ )) ; do
        for (( j=$i + 1 ; j < ${#DUPLICATE_LIST[@]} ; j++ )) ; do
            if [[ ${alreadyRemoved[i]} == 1 ]] ; then
                continue 2
            elif [[ ${alreadyRemoved[j]} == 1 ]] ; then
                continue
            fi

            local hash1=$(md5sum "${DUPLICATE_LIST[i]}" | awk '{print $1}')
            local hash2=$(md5sum "${DUPLICATE_LIST[j]}" | awk '{print $1}')
            if [[ "$hash1" == "$hash2" ]] ; then
                if cmp -s "${DUPLICATE_LIST[i]}" "${DUPLICATE_LIST[j]}" ; then
                    (( duplicatesFound += 1 ))
                    alreadyRemoved[j]=1
                    removeFile "${DUPLICATE_LIST[j]}" "${DUPLICATE_LIST[i]}"
                fi
            fi
        done
    done
}

# funkcja usuwa plik $1 lub jesli podniesiona jest flaga
# HARDLINKS_REPLACE to zastepuje go hardlinkiem do $2
removeFile () {
    file=$1
    aliasFile=$2

    if [[ $HARDLINKS_REPLACE == 1 ]] ; then
        echo "replace $file with link to $aliasFile"
    else
        echo "remove $file"
    fi
}

# wydrukowanie raportu
printReport () {
    echo "Liczba przetworzonych plikow: $processedFiles"
    echo "Liczba znalezionych duplikatow: $duplicatesFound"
    echo "Liczba zastapionych duplikatow: $filesRemoved"
}


########################################################################
# MAIN

# sprawdzenie ktore flagi opcji zostaly uzyte przy uruchomieniu skryptu
PARSED=$(getopt --options="$SHORT_OPTS" --longoptions="$LONG_OPTS" --name "$0" -- "$@") || exit 2
eval set -- "$PARSED"

# przetwarzanie flag opcji
while true ; do
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
if [[ $HELP == 1 ]] ; then
    printHelp
    exit 1
fi

# sprawdzenie czy zostal podany folder
if [[ $# < 1 ]] ; then
    echo "target directory was not set"
    exit 2
else
    DIR=$1
fi

# jesli nie ma dodanie / na koncu nazwy folderu
if [[ ${DIR: -1} != "/" ]] ; then
    DIR="$DIR"/
fi

# sprawdzenie czy podany folder istnieje
if [[ ! -d "$DIR" ]] ; then
    echo "$DIR does not exist or is not a directory"
    exit 3
fi

# stworzenie FILE_LIST
findAndSortFiles

# porownanie plikow na FILE_LIST i usuniecie duplikatow
removeDuplicates

# wydrukowanie raportu koncowego
printReport

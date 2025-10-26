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
# i sortuje liste wzgledem rozmiaru plikow
findAndSortFiles () {
    # wpisanie do FILE_LIST tylko plikow z podanego folderu
    # oraz poddfolderow do MAX_DEPTH poziomow w dol
    
    # stworzenie pliku tymczasowego i wpisanie do niego 
    # wyniku polecenia find
	tempFile=$(mktemp ./tmp01XXXXXX)  
    find $DIR -type f -print0 -maxdepth $MAX_DEPTH > $tempFile
    
    # wypelnienie FILE_LIST
    while IFS= read -r -d '' file ; do
        if [[ "$file" == "$tempFile" ]] ; then
            continue
        fi
		FILE_LIST+=("$file")
        (( processedFiles += 1 ))
	done < $tempFile
    
    # usuniecie pliku tymczasowego
    rm $tempFile
    
    # posortowanie FILE_LIST po rozmiarze
    FILE_LIST=$(for file in ${FILE_LIST[@]} ; do
        echo "$(stat -f%z "$file") $file"
    done | sort -n | awk '{print $2}')
}

# funkcja porownuje $1 plikow z DUPLICATE_LIST
# oraz usuwa/podmienia duplikaty 
compareFiles () {
    local duplicateListSize=$1
    local alreadyRemoved=()
    for (( i=0 ; i < $duplicateListSize ; i++ )) ; do
        alreadyRemoved[i]=0
    done

    # debug
    # echo "potential $duplicateListSize duplicates"
    # for (( i=0 ; i < $duplicateListSize ; i++)) ; do
    #     echo ${DUPLICATE_LIST[i]}
    # done
    # echo ""

    for (( i=0 ; i < $duplicateListSize ; i++ )) ; do
        for (( j=$i + 1 ; j < $duplicateListSize ; j++ )) ; do
            if (( alreadyRemoved[i] == 1 )) ; then
                continue 2
            elif (( alreadyRemoved[j] == 1 )) ; then
                continue
            fi

            local hash1=$(md5sum "${DUPLICATE_LIST[i]}" | awk '{print $1}')
            local hash2=$(md5sum "${DUPLICATE_LIST[j]}" | awk '{print $1}')
            if [[ "$hash1" == "$hash2" ]] ; then
                (( duplicatesFound += 1 ))
                alreadyRemoved[j]=1
                echo "remove ${DUPLICATE_LIST[j]}"
            fi
        done
    done

}

# funkcja iteruje sie po FILE_LIST szukajac plikow o
# takiej samej wielkosci i wywoluje compareFilesFrom
findAndRemoveDuplicates () {
    local currentSize=-1
    local currentDuplicates=0

    for file in $FILE_LIST ; do
        local fileSize=$(stat -f%z "$file")
        
        if (( fileSize > currentSize )) ; then
            if (( currentDuplicates > 1 )) ; then
                compareFiles $currentDuplicates
            fi
            DUPLICATE_LIST=()
            currentDuplicates=0
            currentSize=$fileSize
        fi

        DUPLICATE_LIST+=("$file")
        (( currentDuplicates += 1 ))
    done
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
if (( $HELP == 1 )) ; then
    printHelp
    exit 1
fi

# sprawdzenie czy zostal podany folder
if (( $# < 1 )) ; then
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
findAndRemoveDuplicates

# wydrukowanie raportu koncowego
printReport

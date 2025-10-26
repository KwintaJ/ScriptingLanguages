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

# opcje i ich domyslne wartosci
HELP=0
MAX_DEPTH=20
HASH_ALGO="md5"
HARDLINKS_REPLACE=0

# jedyny argument - docelowy folder
DIR=""

# zmienne operacyjne
declare FILE_LIST
declare FILE_HASH
declare SIZE_LIST
declare DUPLICATE_LIST
declare ALREADY_REMOVED

# zmienne wynikowe
processedFiles=0
duplicatesFound=0
filesLinked=0



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
    find "$DIR" -maxdepth $MAX_DEPTH -type f -print0 | while IFS= read -r -d '' file ; do
        echo "$(stat -c '%s' "$file") $file"
    done > "$tempFile"

    # sortowanie
    sort -n "$tempFile" -o "$tempFile"

    # wypelnienie FILE_LIST
    m=0
    while IFS= read -r line ; do
        local size="${line%% *}"
        local name="${line#* }"
        # pominiecie pliku tymczasowego
        if [[ "$(realpath "$name")" == "$(realpath "$tempFile")" ]] ; then
            continue
        fi

        FILE_LIST[m]="$name"
        SIZE_LIST[m]="$size"
        (( processedFiles += 1 ))
        (( m += 1 ))
    done < "$tempFile"

    # usuniecie pliku tymczasowego
    rm $tempFile

    # obliczenie hash dla każdego pliku
    # i wypełnienie ALREADY_REMOVED
    for (( l=0 ; l < ${#FILE_LIST[@]} ; l++ )) ; do
        FILE_HASH[l]=$("$HASH_ALGO"sum "${FILE_LIST[l]}" | awk '{print $1}')
        ALREADY_REMOVED[l]=0
    done
}

# funkcja iteruje sie po FILE_LIST szukajac plikow o
# takiej samej wielkosci i wywoluje compareFiles
removeDuplicates () {
    local currentSize=-1
    local currentDuplicates=0

    for (( k=0 ; k < ${#FILE_LIST[@]} ; k++ )) ; do
        # dodawanie do listy DUPLICATE_LIST dopoki maja takie same rozmiary
        if [[ ${SIZE_LIST[k]} > $currentSize ]] ; then
            if [[ $currentDuplicates > 1 ]] ; then
                compareFiles
            fi
            unset DUPLICATE_LIST
            currentDuplicates=0
            currentSize=${SIZE_LIST[k]}
        fi
        DUPLICATE_LIST+=("$k")
        (( currentDuplicates += 1 ))
    done
    # ostatnie porownanie - najwiekszy plik/najwieksze pliki
    compareFiles
}

# funkcja porownuje $1 plikow z DUPLICATE_LIST
# oraz usuwa/podmienia duplikaty 
compareFiles () {
    for (( i=0 ; i < ${#DUPLICATE_LIST[@]} ; i++ )) ; do
        for (( j=$i + 1 ; j < ${#DUPLICATE_LIST[@]} ; j++ )) ; do
            local file1=${DUPLICATE_LIST[i]}
            local file2=${DUPLICATE_LIST[j]}

            if [[ ${ALREADY_REMOVED[$file1]} == 1 ]] ; then
                continue 2
            elif [[ ${ALREADY_REMOVED[$file2]} == 1 ]] ; then
                continue
            fi

            if [[ ${FILE_HASH[$file1]} == ${FILE_HASH[$file2]} ]] ; then
                if cmp -s "${FILE_LIST[$file1]}" "${FILE_LIST[$file2]}" ; then
                    (( duplicatesFound += 1 ))
                    ALREADY_REMOVED[$file2]=1
                    removeAndLink "$file2" "$file1"
                fi
            fi
        done
    done
}

# funkcja usuwa plik $1 i jesli podniesiona jest flaga
# HARDLINKS_REPLACE to zastepuje go hardlinkiem do $2
removeAndLink () {
    file=$1
    aliasFile=$2

    if [[ $HARDLINKS_REPLACE == 1 ]] ; then
        rm "${FILE_LIST[$file]}"
        ln "${FILE_LIST[$aliasFile]}" "${FILE_LIST[$file]}"
        (( filesLinked += 1 ))
    fi
}

# wydrukowanie raportu
printReport () {
    echo "Liczba przetworzonych plikow: $processedFiles"
    echo "Liczba znalezionych duplikatow: $duplicatesFound"
    echo "Liczba zastapionych duplikatow: $filesLinked"
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

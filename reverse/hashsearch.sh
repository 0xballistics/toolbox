#!/bin/bash
USAGE="$0 -f [<file>]* -h [<md5|sha1|sha256>]* -s [<search path>]*"
while getopts ":f:h:s:" opt
   do
     case $opt in
        f ) input_file=("$OPTARG")
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                input_file+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
            ;;
        h ) input_hash=("$OPTARG")
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                input_hash+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
            ;;
        s ) search_path=("$OPTARG")
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                search_path+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
            ;;
        : ) echo "$USAGE" 1>&2 && exit 1;;
        \? ) echo "$USAGE" 1>&2 && exit 1;;
     esac
done

if ([ -z $input_file ] | [ -z $input_hash ]) | [ -z $search_path ]; then
    echo "$USAGE" 1>&2 && exit 1
fi

INPUT_NAMES=()
INPUT_TYPES=()
INPUT_VALS=()

for f in "${input_file[@]}"; do
    md5=`md5sum $f | cut -d' ' -f 1`
    if [ -z md5 ];then echo "ERROR" 1>&2 && exit 2;fi
    INPUT_NAMES+=($f)
    INPUT_TYPES+=("md5")
    INPUT_VALS+=($md5)
done

for h in "${input_hash[@]}"; do
    chrlen=${#h}
    if [ $chrlen -eq 32 ];then
        name="[${h:0:12}...]"
        INPUT_NAMES+=($name)
        INPUT_TYPES+=("md5")
        INPUT_VALS+=($h)
    elif [ $chrlen -eq 40 ];then
        name="[${h:0:12}...]"
        INPUT_NAMES+=($name)
        INPUT_TYPES+=("sha1")
        INPUT_VALS+=($h)
    elif [ $chrlen -eq 64 ];then
        name="[${h:0:12}...]"
        INPUT_NAMES+=($name)
        INPUT_TYPES+=("sha256")
        INPUT_VALS+=($h)
    else echo "$h is not md5, sha1 or sha256" 1>&2 && exit 3
    fi
done

SEARCH_FILES=()
# check if dir or file exists for each search path
for s in "${search_path[@]}"; do
    if [ -f $s ] || [ -d $s ];then
        while IFS= read -d $'\0' -r file ; do
            SEARCH_FILES+=("$file")
        done < <(find "$s" -type f -print0)
    else
        echo "$s is not a valid file or directory" 1>&2 && exit 4
    fi
done

SEARCH_NAMES=()
SEARCH_TYPES=()
SEARCH_VALS=()

# check if md5 exists in array, then do a md5 calculation on each file
if [[ " ${INPUT_TYPES[@]} " =~ " md5 " ]]; then
    # do parsing ops and save in SEARCH_FILES, SEARCH_VALS
    for s in "${SEARCH_FILES[@]}"; do
        HSH=`md5sum "$s" | cut -d ' ' -f 1`
        #echo "$s md5 $HSH"
        SEARCH_NAMES+=("$s")
        SEARCH_TYPES+=("md5")
        SEARCH_VALS+=("$HSH")
    done
fi

# repeat for sha1 and sha256
if [[ " ${INPUT_TYPES[@]} " =~ " sha1 " ]]; then
    for s in "${SEARCH_FILES[@]}"; do
        HSH=`sha1sum "$s" | cut -d ' ' -f 1`
        echo "$s sha1 $HSH"
        SEARCH_NAMES+=("$s")
        SEARCH_TYPES+=("sha1")
        SEARCH_VALS+=("$HSH")
    done
fi

# repeat for sha1 and sha256
if [[ " ${INPUT_TYPES[@]} " =~ " sha256 " ]]; then
    for s in "${SEARCH_FILES[@]}"; do
        HSH=`sha256sum "$s" | cut -d ' ' -f 1`
        echo "$s sha256 $HSH"
        SEARCH_NAMES+=("$s")
        SEARCH_TYPES+=("sha256")
        SEARCH_VALS+=("$HSH")
    done
fi

# make matching
INPLEN=${#INPUT_NAMES[@]}
SRCLEN=${#SEARCH_NAMES[@]}
for (( i=0; i<$INPLEN; i++ )); do
    name="${INPUT_NAMES[$i]}"
    val="${INPUT_VALS[$i]}"
    for (( j=0; j<$SRCLEN; j++ )); do
        search_name="${SEARCH_NAMES[$j]}"
        search_val="${SEARCH_VALS[$j]}"
        #printf "DBG: %-26s %-32s %-26s %-32s\n" $name $val $search_name $search_val
        if [ "$val" = "$search_val" ]; then
            printf "%-26s %-26s %-32s\n" "$name" "$search_name" "$val"
        fi
    done
done

#echo ${INPUT_NAMES[@]}
#echo ${SEARCH_NAMES[@]}
#echo ${INPUT_TYPES[@]}
#echo ${INPUT_VALS[@]}
#echo $input_hash
#echo $search_path


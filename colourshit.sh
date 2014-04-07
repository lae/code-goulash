#!/bin/bash
getrand() {
    head /dev/urandom |
    strings |
    tr -d '\n' |
    grep -oP "(1[0-6]|[0-9])" |
    head -n1
}

length=$1
shift

for w in $(seq 1 $length)
do
    printf "\003$(getrand),$(getrand)$*\003"
done |
tr -d '\n' |
fold -w 300 |
perl -pe 's#^.*?(\003\d\d?,\d\d?)#\1#g' |
sed 's/^[^\w]$//'

#!/bin/bash
head -n30 /dev/urandom |
    strings |
    tr -d '\n' |
    sed -r "s/(.)/$(((RANDOM%32))),$(((RANDOM%32)))\1/g"

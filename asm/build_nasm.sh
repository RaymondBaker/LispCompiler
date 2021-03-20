#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "Illegal number of parameters"
fi

filename=$1
without_ext=$(echo $filename | sed 's/\.[^.]*$//')

nasm -felf64 -F dwarf -g $filename && gcc $without_ext.o -o $without_ext && ./$without_ext

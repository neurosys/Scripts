#!/usr/bin/env bash

if command -v batcat &> /dev/null
then
    batcat $*
else 
    while read binary
    do
        if [[ "$binary" != "$HOME/.bin/bat" ]]
        then
            exec $binary "$@"
        fi
    done < <(which -a bat)
    echo "ERR: No suitable 'bat' binary found"
fi

#!/bin/bash

# Version 0.1 ................... Created the script
# Version 0.2 2012-10-11_17-12-29 Added the default creation of /j.bat
#                                 Now only the label for the path is required
# Version 0.3 2012-10-26_14-18-40 Paths that are under the cygwin path but
#                                 outside the /cygdrive/* can't be added to the
#                                 jump script, therefore added an warning
#                                 message and an exit for this case

# TODO if / is not in windows path, add it programmatically
# TODO if path is under cygwin directory structure... pwd is intimidated

# I presume my cygwin's / is in my windows path... and its name is j.bat
jump_script=/j.bat

my_label=$1
my_drive=$(pwd | gawk 'BEGIN{FS="/"};{printf("%s:", $3)}')
my_path=$(pwd | gawk 'BEGIN{FS="/"};{printf("%s:\\\\", $3); for(i=4;i<=NF;i++) printf("%s\\\\",$i);}')
record_exists=0

# Placeholders.
# These are searched and replaced with the new values + themsef
if_place_holder_text="IF_PLACE_HOLDER"
help_place_holder_text="HELP_PLACE_HOLDER"
jump_place_holder_text="JUMP_PLACE_HOLDER"

# .bat labels
# These are the labels that will be used to separate different sections of the .bat script
normal_end_label="NORMAL_END"
help_needed_end_label="HELP_NEEDED_END"

help_header_text="Installed jumps"

function create_template_file()
{
cat > "$jump_script" <<j_bat_file_template
@echo off

REM $if_place_holder_text

GOTO $help_needed_end_label

REM $jump_place_holder_text

:$normal_end_label
exit

:$help_needed_end_label

@echo $help_header_text
REM $help_place_holder_text

j_bat_file_template
}


if [ ! -f "$jump_script" ] ; then
    echo "$jump_script does not exist! Creating file..."
    create_template_file
fi


if [ -z "$1" ] ; then
    echo -e "\nUsage: jumper <label>\n"
    echo -e "\tlabel: the word to label the current path\n\n"
    exit 0
fi

pwd | egrep "^/cygdrive" --max-count=1 --no-message > /dev/null
if [[ $? -eq 1 ]] ; then
    echo "Because this dir is under the cygwin path, this directory can not be handled properly, please add it manually"
    exit 1
fi

if [[ $3 -eq 1 ]] ; then
    echo "Label =" $my_label
    echo "Drive =" $my_drive
    echo "Path =" $my_path
fi


cat $jump_script | grep ":$my_label\>" --max-count=1 --no-message > /dev/null 
if [[ $? -eq 0 ]] ; then
    record_exists=1
    echo "That label already exists"
    echo "Try other values, maybe you're more lucky, to see a list of all the things defined, run $jump_script with no parameters"
    exit 0
fi

if [[ $record_exists -eq 0 ]] ; then
    # Replace the placeholders with the real values and add new placeholders

    sed -e "s/REM $if_place_holder_text/if \"%1\" == \"$my_label\" GOTO $my_label\nREM $if_place_holder_text/" \
        -e "s/REM $help_place_holder_text/@echo $my_label $my_path\nREM $help_place_holder_text/" \
        -e "s/REM $jump_place_holder_text/:$my_label\n\t$my_drive\n\tchdir $my_path\n\tGOTO $normal_end_label\nREM $jump_place_holder_text/" \
        -i $jump_script

    # Extract the help information
    registered_paths=$(sed -n "/@echo $help_header_text/,//p" $jump_script |\
        sed -e "s/@echo $help_header_text//" -e "s/REM $help_place_holder_text//" -e "/^$/d")

    # Remove the current help
    sed -i "/@echo $help_header_text/,//d" $jump_script

    # Append the help header
    echo "@echo $help_header_text" >> $jump_script

    # Append back the help, in a sorted manner
    #echo "$registered_paths" | sort >> $jump_script
    echo "$registered_paths" | sed -e "s/\(@echo [a-zA-Z0-9]*\)/\1 =/" | sort | column -t -s = >> $jump_script

    # Append the help place holder
    echo "REM $help_place_holder_text" >> $jump_script


    sleep 1

    # Somebody messed up and I'm too lazy to search who's fault is
    #unix2dos $jump_script &> /dev/null
    sed -e 's/$'"/`echo \\\r`/" -i "$jump_script"
fi


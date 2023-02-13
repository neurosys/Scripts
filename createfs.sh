#!/usr/bin/env bash

nameOfFile=
size=
fsType=
encrypt=
debug=0
nameOfTemporaryEncryptedVolume=myEncVolume
defaultFsType=ext4

#-------------------------------------------------------------------------------
MIN_NR_OF_ARGS=4

function help() {
    echo "
     createfs.sh --file <file name> --size <size> 
         size units M, G
     --encrypt (encrypted)
     --fstype <filesystem>
         ext2, ext3, ext4, swap, vfat, ntfs

    Use following command to mount:
        If the FS is encrypted
        sudo cryptsetup luksOpen <nameOfFile> <encVolume>
        sudo mount -t <fstype> -rw -o loop /dev/mapper/<encVolume> <mount point>

        If the FS is not encrypted
        sudo mount -t <fstype> -rw -o loop <fileName> <mount point>

        If the FS is swap
        sudo swapon <fileName>
     "
}

function parseArguments() {
    while [[ -n $1 ]]
    do
        case $1 in
            "--file")
                nameOfFile=$2
                shift
                ;;
            "--size")
                size=$2
                shift
                ;;
            "--encrypt")
                encrypt=1
                ;;
            "--fstype")
                fsType=$2
                shift
                ;;

            *)
                echo "Unknown parameter '$1'"
                help
                exit 1
                ;;
        esac
        shift
    done

    if [[ -z $fsType ]]
    then
        fsType=$defaultFsType
    fi
}

function parseSizeUnits() {
    local output=$1
    local splitedSize=$2
    local unit=
    echo $size | grep "[0-9]\+G\>" 2>&1 > /dev/null
    if [[ $? -eq 0 ]]
    then
        # G means 1024^3 bytes
        unit=G
    fi

    echo $size | grep "[0-9]\+M\>" 2>&1 > /dev/null
    if [[ $? -eq 0 ]]
    then
        # M means 1024^2 bytes
        unit=M
    fi

    if [[ -z $unit ]]
    then
        echo "ERROR: Unknown unit provided size '$size' pleas use only M or G suffixes"
        exit 1
    fi

    local numericSize=$(echo "$size" | grep -o "^[0-9]\+")

    eval "$splitedSize='$numericSize'"
    eval "$output='$unit'"
}

function allocateEmptyFile() {
    local computedSize=
    local sizeUnits=
    parseSizeUnits parsedSizeUnits computedSize
    
    echo "Allocating empty file space of ${computedSize} ${parsedSizeUnits}"
    echo "-------------- dd output ------------------------------"
    if [[ $debug -eq 0 ]]
    then
        dd if=/dev/zero of=$nameOfFile bs=1${parsedSizeUnits} count=${computedSize} "status=progress"
    fi
    echo "======================================================="
    echo -e "\n"
}

function createEncryptedVolume() {
    echo "Creating the encrypted volume. (requires root)"
    echo "You will also need to provide the password for the new volume"
    echo "-------------- cryptsetup output ---------------------"
    sudo cryptsetup -y luksFormat $nameOfFile
    echo "======================================================="
    echo -e "\n"
}

function mountEncryptedVolume() {
    echo "Mounting the encrypted volume. (requires root)"
    echo "You will also need to provide the password for the new volume"
    echo "-------------- cryptsetup output ---------------------"
    sudo cryptsetup luksOpen $nameOfFile $nameOfTemporaryEncryptedVolume
    echo "======================================================="
    echo -e "\n"
}

function unmountEncryptedVolume() {
    echo "Closing the encrypted volume. (requires root)"
    echo "-------------- cryptsetup output ---------------------"
    sudo cryptsetup close /dev/mapper/$nameOfTemporaryEncryptedVolume
    echo "======================================================="
    echo -e "\n"
}

function createFileSystem() {
    local deviceName=$1
    local fileSystemType=$2
    echo "Creating filesystem ($fileSystemType) on $deviceName"
    echo "-------------------- mkfs output ---------------------"
    sudo mkfs -t $fileSystemType $deviceName
    echo "======================================================="
    echo -e "\n"
}

function main() {
    if [[ $# -lt $MIN_NR_OF_ARGS ]]
    then
        help 
        exit 1
    fi

    if [[ $UID -ne 0 ]]
    then
        echo "You need to run as root"
        exit 1
    fi

    parseArguments $*

    allocateEmptyFile

    if [[ $fsType == swap ]]
    then
        echo "Making swap (root)"
        sudo mkswap $nameOfFile
        exit 0
    fi

    local fsDeviceName=$nameOfFile
    if [[ $encrypt -eq 1 ]]
    then
        #echo "Creating an encrypted container (root)"
        createEncryptedVolume
        mountEncryptedVolume
        fsDeviceName=/dev/mapper/$nameOfTemporaryEncryptedVolume
    fi

    createFileSystem $fsDeviceName $fsType

    if [[ $encrypt -eq 1 ]]
    then
        #echo "Unmounting the encrypted container (root)"
        unmountEncryptedVolume
    fi

}

main $*
exit 0 


echo "Allocating file space"
dd if=/dev/zero of=$nameOfFile bs=1$measureUnit count=$size
if [[ $? -eq 1 ]]
then
    echo "ERROR: Allocating space failed"
    return
fi

if [[ $fileType == "-e" ]]
then
    # Create an encrypted format
    sudo cryptsetup -y luksFormat $nameOfFile

    # Open the encrypted container 
    sudo cryptsetup luksOpen $nameOfFile encVolume
    nameOfFile=encVolume
fi

# Create filesystem in the file specified being 
mkfs -t ext4 $nameOfFile

#mkfs -t fileSystem  $fileName


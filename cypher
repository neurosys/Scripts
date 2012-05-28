#!/usr/bin/env bash
#
# Version 0.2 2012-05-02
#
# Coded by NeuroSys in an atempt to build something useful for day to day use
#

BASENAME=$(basename $0)
SCRIPT=$(which $BASENAME)
E_BAD_PARAMS=1
E_MISSING_INPUT_FILE=2
GREP_OPTIONS=

# File extensions
AES_ENC_FILE=.aes_enc
AES_KEY_FILE=.aes_key.rsa_enc
HASH_FILE=.sha.aes_enc


# TODO
# - Use getopts for the parameters
# - Preserve the same time for the files

 function print_documentation()
{
    local function_name=${1:-general}
    # Print documentation for the coresponding function, and strip the heredoc tags
    sed -n "/:<<$function_name\$/,/^$function_name\$/p" $SCRIPT |\
    sed -e "s/:<<$function_name//" -e "s/{BASENAME}/$function_name/" -e "s/^$function_name\$//"
}

 function missing_file()
{
    echo "Missing file ${2}"
    echo
    print_documentation $1
}

:<<aes_256_encrypt
=Encrypt data using AES-256-cbc=

Usage: {BASENAME} aes_256_encrypt -passwd <password> [-input <input file>] [-output <output file>]
    default input file = stdin
    default output file = stdout
aes_256_encrypt
function aes_256_encrypt()
{
    while [ -n "$1" ]
    do
        case "$1" in
            "-passwd") passwdord="$2" ;;
            "-input")   input_file=$(if [ -n "$2" ] ; then echo "$2" ; fi ) ;;
            "-output") output_file=$(if [ -n "$2" ] ; then echo "-out \"$2\"" ; fi ) ;;
        esac
        shift
    done

    if [ -n "$input_file" ]
    then
        if  [ ! -f "$input_file" ]
        then
            missing_file $FUNCNAME $2
            exit $E_MISSING_INPUT_FILE
        fi
        input_file="-in \"$input_file\" "
    fi

    local openssl_params=${input_file}${output_file}

    if [ -z $passwdord ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi
    openssl enc -e -aes-256-cbc -k "$password" $openssl_params
}

:<<aes_256_decrypt
=Decrypt data using AES-256-cbc=

Usage: {BASENAME} aes_256_decrypt -passwd <password> [-input <input file>] [-output <output file>]
    default input file = stdin
    default output file = stdout
aes_256_decrypt
function aes_256_decrypt()
{
    while [ -n "$1" ]
    do
        case "$1" in
            "-passwd") local passwdord="$2" ;;
            "-input")  local input_file=$(if [ -n "$2" ] ; then echo "$2" ; fi ) ;;
            "-output") local output_file=$(if [ -n "$2" ] ; then echo "-out \"$2\" " ; fi ) ;;
        esac
        shift
    done

    if [ -n "$input_file" ]
    then
        if  [ ! -f "$input_file" ]
        then
            missing_file "$FUNCNAME" "$2"
            exit $E_MISSING_INPUT_FILE
        fi
        input_file="-in \"$input_file\" "
    fi

    local openssl_params=${input_file}${output_file}

    if [ -z $passwdord ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi
    openssl enc -d -aes-256-cbc -k "$password" $openssl_params
}

:<<cryptor
Usage: {BASENAME} <input file> <public key pem file> [<password length>]
cryptor
function cryptor()
{

    if [ "$1" = "" ] || [ "$2" = "" ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi

    local file_to_be_encrypted=$1
    local output_encrypted_file="${file_to_be_encrypted}${AES_ENC_FILE}"
    local public_key_file=$2
    local output_encrypted_aes_key_file="${file_to_be_encrypted}${AES_KEY_FILE}"
    local output_encrypted_hash="${file_to_be_encrypted}${HASH_FILE}"

    if [ ! -f "$file_to_be_encrypted" ]
    then
        missing_file $FUNCNAME "$file_to_be_encrypted"
        exit $E_MISSING_INPUT_FILE
    fi

    if [ ! -f "$public_key_file" ]
    then
        missing_file $FUNCNAME "$public_key_file"
        exit $E_MISSING_INPUT_FILE
    fi

    local password_length=${3:-256}

    # Generate a password for the AES encryption
    local password=$(openssl rand -base64 $password_length)

    # Encrypt the target file
    openssl enc -e -aes-256-cbc -in "$file_to_be_encrypted" -out "$output_encrypted_file" -k "$password"

    # Save the sha512 into a file
    cat $file_to_be_encrypted | openssl dgst -sha512 | openssl enc -e -aes-256-cbc -out "$output_encrypted_hash" -k "$password"

    # RSA encrypt the password for the target file
    echo "$password" | openssl rsautl -out "$output_encrypted_aes_key_file" -inkey "$public_key_file" -pubin -encrypt
}


:<<decryptor
Usage: {BASENAME} <encrypted file> <private key>"
decryptor
function decryptor()
{
    if [ "$1" = "" ] || [ "$2" = "" ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi

    local encrypted_file="$1"
    local encrypted_password=$( echo $1 | sed -e "s;$AES_ENC_FILE\$;$AES_KEY_FILE;" )
    local private_key="$2"
    local password_for_private_key="$3" # sometimes private keys are encrypted
    local encrypted_hash=$( echo $1 | sed -e "s;$AES_ENC_FILE\$;$HASH_FILE;" )
    local no_file_has=0

    local output_file=$(echo "$encrypted_file" | sed -e "s;$AES_ENC_FILE\$;;")

    if [ ! -f "$encrypted_file" ]
    then
        missing_file $FUNCNAME "$encrypted_file"
        exit $E_MISSING_INPUT_FILE
    fi

    if [ ! -f "$encrypted_password" ]
    then
        missing_file $FUNCNAME "$encrypted_password"
        exit $E_MISSING_INPUT_FILE
    fi

    if [ ! -f "$encrypted_hash" ]
    then
        missing_file $FUNCNAME "$encrypted_hash"
        echo "Ignorring file integrity"
        no_file_has=1
    fi

    # RSA Decrypt the AES key
    local aes_key=$(openssl rsautl -in "$encrypted_password" -inkey "$private_key" -decrypt)

    # Decrypt AES256 the file
    openssl enc -d -aes-256-cbc -in "$encrypted_file" -out $output_file -k "$aes_key"

    if [ 0 -eq $no_file_has ]
    then
        # Decrypt AES256 the hash of the file
        local stored_hash=$(openssl enc -d -aes-256-cbc -in "$encrypted_hash" -k "$aes_key")
        local computed_hash=$( cat $output_file | openssl dgst -sha512 )

        if [ "$stored_hash" != "$computed_hash" ]
        then
            echo "File has been tampered with"
            echo "Computed = $computed_hash"
            echo "Stored = $stored_hash"
        fi
    fi
}

:<<genkey
=Generate RSA pair of keys=

Usage: {BASENAME} genkey <private key file> <public key file> [<key size>]
Note: the private key will be encrypted using aes-256-cbc
genkey
function genkey()
{
    if [ "$1" = "" ] || [ "$2" = "" ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi
    local output_private_key="$1"
    local output_public_key="$2"
    local private_key_size=${3:-4096}

    # Generate private key in pem format
    openssl genrsa -aes256 -out "$output_private_key" "$private_key_size"

    # Generate public key
    openssl rsa -in "$output_private_key" -pubout -out "$output_public_key"
}

:<<decrypt_private_key
= Decrypt RSA private key =

Usage: {BASENAME} <encrypted private key> <output plain private key>
decrypt_private_key
function decrypt_private_key()
{
    if [ -z "$1" ] || [ -z "$2" ]
    then
        print_documentation $FUNCNAME
        exit $E_BAD_PARAMS
    fi

    if [ -f "$1" ]
    then
        openssl rsa -in $1 -out $2
    else
        missing_file $FUNCNAME $1
    fi
}


 function main()
{
    local cmd=$1
    shift

    if [ -n "$cmd" ]
    then
        grep -q "^function $cmd()" $SCRIPT
        if [ $? -eq 0 ]
        then
            eval $cmd $*
            exit $?
        fi
    fi

    echo "Usage: call one of these functions:"
    grep "^function " $SCRIPT | sed -e 's/function/   /' -e 's;();;'
    echo "For help type $SCRIPT <function name>"
    exit $E_BAD_PARAMS
}

main $*

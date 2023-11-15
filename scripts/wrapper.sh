#! /bin/bash

ENCRYPTION=false
DECRYPTION=false
SIGNING=false
VERIFY_SIGNING=false

ENC_KEY="HS/SRK/ENC_KEY"
SIGN_KEY="HS/SRK/SIGN_KEY"
PUB_SIGN_KEY="/PUB_KEY"

# Get SHA256 digest of file and save it to file the digest is truncated to 31 characters because of the TPM 2.0 limitation
#
# $1 - input file path
# $2 - output file path (optional) - default: digest
#
# Returns output file path
sha256() {
    local INPUT_FILE_PATH="$1"
    local OUTPUT_FILE_PATH="${2:-digest}"

    cat "$INPUT_FILE_PATH" | sha256sum | cut -d ' ' -f1 | cut -c-31 > "$OUTPUT_FILE_PATH"

    echo "$OUTPUT_FILE_PATH"
}

# Import key to TPM
#
# $1 - input object file path
# $2 - key path in TPM (optional) - default: PUB_SIGN_KEY
import_key() {
    local INPUT_OBJECT="$1"
    local KEY_PATH="${1:-$PUB_SIGN_KEY}"

    if ! [[ "$(tss2_list)" == *"ext/$KEY_PATH"* ]]; then
        tss2_import \
            -p $KEY_PATH \
            -i $INPUT_OBJECT
    else
        echo "Already imported"
    fi
}

# Sign
#
# $1 - digest file path generated by sha256 function
# $2 - signature file path (optional) - default: signature - output file
# $3 - public key file path (optional) - default: pub_key - output file
# $4 - key path in TPM (optional) - default: SIGN_KEY
#
# Returns public key file path
sign() {
    local DIGEST="$1"
    local SIGNATURE="${2:-signature}"
    local PUB_KEY="${3:-pub_key}"
    local KEY_PATH="${4:-$SIGN_KEY}"

    tss2_sign \
        -p "$KEY_PATH" \
        -d "$DIGEST" \
        -o "$SIGNATURE" \
        -k "$PUB_KEY"
    
    echo "$PUB_KEY"
}

# Verify signature
#
# $1 - digest file path generated by sha256 function
# $2 - signature file path (optional) - default: signature
# $3 - key path in TPM (optional) - default: PUB_SIGN_KEY
verify_sign() {
    local DIGEST="$1"
    local SIGNATURE="${2:-signature}"
    local KEY_PATH="${3:-$PUB_SIGN_KEY}"

    tss2_verifysignature \
        -p "/ext$KEY_PATH" \
        -d "$DIGEST" \
        -i "$SIGNATURE"
        
    if [ $? -ne 0 ]; then
        echo "Invalid Sign"
        exit 1
    fi
}

# Encrypt file
#
# $1 - input file path
# $2 - output file path
# $3 - key path in TPM (optional) - default: ENC_KEY
encrypt() {
    local INPUT_FILE_PATH="$1"
    local OUTPUT_FILE_PATH="$2"
    local KEY_PATH="${3:-$ENC_KEY}"
    
    tss2_encrypt \
        -p "$KEY_PATH" \
        -i "$INPUT_FILE_PATH" \
        -o "$OUTPUT_FILE_PATH"
}

# Decrypt file
#
# $1 - input file path
# $2 - output file path
# $3 - key path in TPM (optional) - default: ENC_KEY
decrypt() {
    local INPUT_FILE_PATH="$1"
    local OUTPUT_FILE_PATH="$2"
    local KEY_PATH="${3:-$ENC_KEY}"
    
    tss2_decrypt \
        -p "$KEY_PATH" \
        -i "$INPUT_FILE_PATH" \
        -o "$OUTPUT_FILE_PATH"
}

# Cleanup files
#
# $@ - files to remove
cleanup() {
    local files=("$@")

    for file in ${files[@]}; do
        rm $file
    done
}

# Print help message
help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message and exit"
    echo "  -d, --decrypt           Decrypt file"
    echo "  -e, --encrypt           Encrypt file"
    echo "  -s, --sign              Sign file"
    echo "  -v, --verify            Verify signature"
    echo "  -k, --key-path          Key path in TPM"
    echo "  -o, --output            Output file name"
    echo "  -p, --file-path         File path"
    echo ""
    echo "Example:"
    echo "  $0 -e -s -o <encrypted-file-name> -p <input-file-name>"
    echo "  $0 -d -v -o <decripted-file-name> -p <encrypted-file-name>"
    echo "  $0 -e -s -k HS/SRK/ENC_KEY -o <encrypted-file-name> -p <input-file-name>"
    echo "  $0 -d -v -k HS/SRK/ENC_KEY -o <decripted-file-name> -p <encrypted-file-name>"
    exit 1
}

# Handle options
#
# $@ - options
handle_options() {
    [ $# -eq 0 ] && help

    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                help
                exit 0
                ;;
            -d | --decrypt)
                DECRYPTION=true
                ;;
            -e | --encrypt)
                ENCRYPTION=true
                ;;
            -s | --sign)
                SIGNING=true
                ;;
            -v | --verify)
                VERIFY_SIGNING=true
                ;;
            -k | --key-path) 
                KEY_PATH="$2"
                ! [[ "$(tss2_list)" == *"$KEY_PATH"* ]] && echo "Key does not exist" && exit 1
                shift
                ;;
            -o | --output)
                OUTPUT_FILE_NAME="$2"
                shift
                ;;
            -p | ---file-path)
                INPUT_FILE_NAME="$2"
                [[ ! -f "$INPUT_FILE_NAME" ]] && echo "File does not exist" && exit 1
                shift
                ;;
            *)
                echo "Invalid option: $1" >&2
                help
                exit 1
                ;;
        esac
        shift
    done
}

# Main function
main() {
    if [ "$ENCRYPTION" == true ]; then
        echo "### ENCRYPTION ###"
        encrypt $INPUT_FILE_NAME $OUTPUT_FILE_NAME

        if [ "$SIGNING" == true ]; then
            echo "### SHA256 ###"
            SHA_OUTPUT_FILE=$(sha256 $OUTPUT_FILE_NAME)

            echo "### SIGN ###"
            PUB_KEY=$(sign "$SHA_OUTPUT_FILE")

            echo "### IMPORT KEY ###"
            import_key $PUB_KEY

            echo "### CLEANUP ###"
            file_to_clean=($SHA_OUTPUT_FILE $PUB_KEY)
            cleanup "${file_to_clean[@]}"
        fi
    elif [ "$DECRYPTION" == true ]; then
        if [ "$VERIFY_SIGNING" == true ]; then
            echo "### SHA256 ###"
            SHA_OUTPUT_FILE=$(sha256 $INPUT_FILE_NAME)

            echo "### VERIFY SIGN ###"
            verify_sign $SHA_OUTPUT_FILE

            echo "### CLEANUP ###"
            file_to_clean=($SHA_OUTPUT_FILE)
            cleanup "${file_to_clean[@]}"
        fi

        echo "### DECRYPT ###"
        decrypt $INPUT_FILE_NAME $OUTPUT_FILE_NAME
    fi
}

handle_options "$@"

main
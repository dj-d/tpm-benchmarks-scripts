#! /bin/bash

source ./globals.sh
source ./tpm.sh
source ./utility.sh

CREATE_KEY=false
ENCRYPTION=false
DECRYPTION=false
SIGNING=false
VERIFY_SIGNING=false

# Handle options
#
# $@ - options
handle_options() {
    [ $# -eq 0 ] && help

    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                help
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
            -i | --init)
                CREATE_KEY=true
                ;;
            --encption-key)
                ENC_KEY="$2"
                shift
                ;;
            --sign-key)
                SIGN_KEY="$2"
                shift
                ;;
            --signature)
                SIGNATURE="$2"
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                help
                ;;
        esac
        shift
    done
}

# Main function
main() {
    handle_options "$@"

    if [ "$CREATE_KEY" == true ]; then
        echo "### CREATE KEY ###"
        create_key "$ENC_KEY" "decrypt"
        create_key "$SIGN_KEY" "sign"
    elif [ "$ENCRYPTION" == true ]; then
        echo "### ENCRYPTION ###"
        encrypt "$INPUT_FILE_NAME" "$OUTPUT_FILE_NAME"

        if [ "$SIGNING" == true ]; then
            echo "### SHA256 ###"
            SHA_OUTPUT_FILE=$(sha256 "$OUTPUT_FILE_NAME")

            echo "### SIGN ###"
            PUB_KEY=$(sign "$SHA_OUTPUT_FILE" "$SIGNATURE")

            echo "### IMPORT KEY ###"
            import_key $PUB_KEY

            echo "### CLEANUP ###"
            file_to_clean=("$SHA_OUTPUT_FILE" "$PUB_KEY")
            cleanup "${file_to_clean[@]}"
        fi
    elif [ "$DECRYPTION" == true ]; then
        if [ "$VERIFY_SIGNING" == true ]; then
            echo "### SHA256 ###"
            SHA_OUTPUT_FILE=$(sha256 "$INPUT_FILE_NAME")

            echo "### VERIFY SIGN ###"
            verify_sign "$SHA_OUTPUT_FILE" "$SIGNATURE"

            echo "### CLEANUP ###"
            file_to_clean=($SHA_OUTPUT_FILE)
            cleanup "${file_to_clean[@]}"
        fi

        echo "### DECRYPT ###"
        decrypt $INPUT_FILE_NAME $OUTPUT_FILE_NAME
    fi

    echo "### DONE ###"
}

main "$@"
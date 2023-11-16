#! /bin/bash

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
    echo "  -s, --sign              Sign file (optional)"
    echo "  -v, --verify            Verify signature (optional)"
    echo "  -k, --key-path          Key path in TPM (optional) - default: ENC_KEY"
    echo "  -o, --output            Output file name"
    echo "  -p, --file-path         File path"
    echo "  -i, --init              Initialize TPM keys"
    echo "  --encption-key          Encryption key path in TPM (optional) - default: ENC_KEY"
    echo "  --sign-key              Signing key path in TPM (optional) - default: SIGN_KEY"
    echo "  --signature             Signature file name (optional) - default: signature"
    echo ""
    echo "Examples:"
    echo "  Initialize TPM keys:"
    echo "      $0 -i"
    echo ""
    echo "  Encrypt file:"
    echo "      $0 -e -s -o <encrypted-file-name> -p <input-file-name>"
    echo "  or:"
    echo "      $0 -e -s -k <tpm-key-path> -o <encrypted-file-name> -p <input-file-name>"
    echo ""
    echo "  Decrypt file:"
    echo "      $0 -d -v -o <decripted-file-name> -p <encrypted-file-name>"
    echo "  or:"
    echo "      $0 -d -v -k <tpm-key-path> -o <decripted-file-name> -p <encrypted-file-name>"
    echo ""
    echo "  Key path format: HS/SRK/<key-name> or HS/SRK/<key-name>/<key-name>"
    exit 0
}
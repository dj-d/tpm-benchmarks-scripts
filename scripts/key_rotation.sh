#! /bin/bash

# Roll up keys
#
# $1 - start iteration
# $2 - end iteration
roll_up() {
    START=$1
    END=$2

    # for i in {$START..$END}; do
    for (( i=$(($START - 1)); i < $END; i++ )); do
        echo "Iteration: $(($i + 1))"
        echo ""

        ./wrapper.sh \
            -e -s \
            -p ./enc_keys/key_$i \
            -o ./enc_keys/key_$(($i + 1)) \
            --signature ./sign_keys/key_$(($i + 1))
    done
}

# Unroll keys
# 
# $1 - start iteration
# $2 - end iteration
unroll() {
    START=$1
    END=$2

    for (( i=$END; i>=$START; i-- )); do
        echo "Iteration: $i"
        echo ""

        ./wrapper.sh \
            -d -v \
            -p ./enc_keys/key_$i \
            -o ./dec_keys/key_$(($i - 1)) \
            --signature ./sign_keys/key_$i
        
        echo ""
    done
}

# Cleanup test data
cleanup() {
    rm -r dec_keys/ enc_keys/ sign_keys/
}

# Print help message
help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message and exit"
    echo "  -p, --plaintext         Plaintext file"
    echo "  -s, --start             Start iteration"
    echo "  -e, --end               End iteration"
    echo ""
    echo "Examples:"
    echo "  $0 -s <start-iteration> -e <end-iteration> -p <initial-key-plaintext>"
    echo "  $0 -s 1 -e 50 -p \"my_encryption_key\""
    echo ""
    exit 0
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
            -p | --plaintext)
                PLAINTEXT="$2"
                shift
                ;;
            -s | --start)
                START="$2"
                shift
                ;;
            -e | --end)
                END="$2"
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                help
                exit 1
                ;;
        esac
        shift
    done
}

# Main function
main() {
    handle_options "$@"

    if ! [[ $START =~ ^[0-9]+$ ]]; then
        echo "Start iteration must be an integer"
        exit 1
    fi

    if ! [[ $END =~ ^[0-9]+$ ]]; then
        echo "End iteration must be an integer"
        exit 1
    fi
    
    if [ $START -le 0 ]; then
        echo "Start iteration must be greater than 0"
        exit 1
    fi

    if [ $END -le $START ]; then
        echo "End iteration must be greater than start iteration"
        exit 1
    fi

    mkdir -p enc_keys
    mkdir -p dec_keys
    mkdir -p sign_keys

    echo "$PLAINTEXT" > ./enc_keys/key_0

    echo "### ROLL UP ###"
    echo ""
    roll_up ${START} ${END}
    
    echo ""
    
    echo "### UNROLL ###"
    echo ""
    time unroll $START $END

    echo ""
    echo "### CLEANUP ###"
    cleanup
}

main "$@"
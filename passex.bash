#!/bin/bash

# Function to display usage information
display_help() {
    echo "Password Extractor Script"
    echo "-------------------------"
    echo "This script extracts words matching a pattern from a list of passwords."
    echo ""
    echo "Usage: $0 [-t time_interval] pattern"
    echo ""
    echo "Options:"
    echo "  -t, --interval     Specify the time interval in seconds between each output (default: 0)"
    echo "  -h, --help         Display this help message and exit"
    echo ""
    echo "Example:"
    echo "  $0 -t5 meow"
    echo "  -t5: Outputs one word every 5 seconds that matches the regex pattern 'meow'"
    exit 0
}

extract_words() {
    content="$1"
    pattern="$2"
    extracted_words=$(echo "$content" | grep -oE "\b$pattern\w*\b")
    echo "$extracted_words"
}

time_interval=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t | --interval )
            time_interval="$2"
            shift 2
            ;;
        -h | --help )
            display_help
            ;;
        * )
            pattern="$1"
            shift
            ;;
    esac
done

# Check if pattern argument is missing
if [ -z "$pattern" ]; then
    echo "Error: Missing pattern argument"
    echo "Usage: $0 [-t time_interval] pattern"
    exit 1
fi

url="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"
content=$(curl -s "$url")

if [ "$time_interval" -eq 0 ]; then
    # Run without delay
    echo "Warning: Running without delay (-t0) will output all matches at once."
    echo "Not suitable for streaming or bruteforcing"
    echo "Are you sure you want to continue? (y/n)"
    read confirm
    if [ "$confirm" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
    extracted_words=$(extract_words "$content" "$pattern")
    echo "Extracted words:"
    echo "$extracted_words"
else
    echo "Extracted words (getting one word every $time_interval second(s)):"
    words_array=($(extract_words "$content" "$pattern"))
    words_count=${#words_array[@]}
    
    idx=0
    while true; do
        echo "${words_array[$idx]}"
        idx=$(( (idx + 1) % words_count ))
        sleep "$time_interval"
    done
fi

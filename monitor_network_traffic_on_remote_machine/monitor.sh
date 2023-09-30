#!/bin/bash

REMOTE_USER=root
REMOTE_HOST=""

print_help() {
  echo "Usage: $0 --host hostname [-u|--user username] [tcpdump_options]"
  echo ""
  echo "Options:"
  echo "  --host hostname        Hostname or IP address of the remote host"
  echo "  -u, --user username    Username to use when connecting to the remote host. Default is 'root'"
  echo "  -h, --help             Print this help"
}

which wireshark >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ERROR: Wireshark is not installed."
    exit 1
fi

which ssh >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ERROR: ssh is not installed."
    exit 1
fi

for o in "$@"; do
    case "$o" in
        -u|--user)
            REMOTE_USER="$2"
            shift 2
            ;;
        --host)
            REMOTE_HOST="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ "$REMOTE_HOST" == "" ]]; then
    echo "ERROR: Missing remote host."
    echo ""
    print_help

    exit 1
fi


TCP_OPTIONS="$@"

# Generate temporary fifo file
FILEPATH="/tmp/$(date +%Y%m%d%H%M%S)_$$_$RANDOM"
mkfifo "$FILEPATH"

nohup ssh "$REMOTE_USER"@"$REMOTE_HOST" "tcpdump -s 0 -U -n -w - $TCP_OPTIONS" > "$FILEPATH" 2>"$FILEPATH.err" </dev/null &

wireshark -k -i "$FILEPATH"

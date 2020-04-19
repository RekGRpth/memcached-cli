#!/bin/sh

memcached_help() {
    cat << EOF
This sets a key on the memcached server.
This retrieves a key from the memcached server.
This lists the keys on the memcached server.
This is able to connect to local and remote memcached servers.
The data to set is taken from stdin.
Usage: $0 options
Options:
 -h This help message
 -C [COMMAND] Command to execute. Available commands is add, append, prepend, replace, set, decr, delete, incr, get, stats, touch, list.
 -E [EXPTIME] Expiration time in seconds, 0 mean no delay, if exptime is superior to 30 day, memcached will use it as a UNIX timestamps for expiration.
 -F [FLAGS] 32-bit unsigned integer that the server store with the data (provided by the user), and return along the data when the item is retrieved.
 -H [HOST] Memcached host to connect to. Default is MEMCACHED_HOST environment variable if it set or localhost else.
 -K [KEY] The key of the data stored.
 -N [NOREPLY] Optional parameter that inform the server to not send the reply.
 -P [PORT] Memcached port to connect to. Default is MEMCACHED_PORT environment variable if it set or 11211 else.
 -V [VALUE] The data to stored.
EOF
}

memcached_error () {
    echo "$@" 1>&2
    memcached_help
    exit 1
}

memcached_4() {
    echo -e "$1 $2\r" | nc "$3" "$4"
}

memcached_5() {
    echo -e "$1 $2 $3\r" | nc "$4" "$5"
}

memcached_6() {
    echo -e "$1 $2 $3 $4\r" | nc "$5" "$6"
}

memcached_8() {
    echo -e "$1 $2 $3 $4 ${#6} $5\r\n$6\r" | nc "$7" "$8"
}

memcached_cachedump() {
    local count=0
    while read cache number; do
        echo -e "stats cachedump $cache $number\r" | nc "$1" "$2" | sed -e '$ d' | cut -d' ' -f 2
    done
}

COMMAND=
EXPTIME=0
FLAGS=0
HOST="${MEMCACHED_HOST:-"localhost"}"
KEY=
NOREPLY=
PORT="${MEMCACHED_PORT:-"11211"}"
VALUE=

while getopts "hC:E:F:H:K:NP:V:" option; do
    case "$option" in
        h) memcached_help && exit ;;
        C) COMMAND="$OPTARG" ;;
        E) EXPTIME="$OPTARG" ;;
        F) FLAGS="$OPTARG" ;;
        H) HOST="$OPTARG" ;;
        K) KEY="$OPTARG" ;;
        N) NOREPLY=noreply ;;
        P) PORT="$OPTARG" ;;
        V) VALUE="$OPTARG" ;;
        *)
            memcached_help
            exit 1
        ;;
    esac
done

if [ -z "$COMMAND" ]; then
    memcached_error "You must specify a command to execute"
fi

case "$COMMAND" in
    add | append | prepend | replace | set)
        if [ -z "$KEY" ]; then
            memcached_error "You must specify a key to $COMMAND"
        fi
        if [ -z "$VALUE" ]; then
            VALUE="$(cat -)"
        fi
        memcached_8 "$COMMAND" "$KEY" "$FLAGS" "$EXPTIME" "$NOREPLY" "$VALUE" "$HOST" "$PORT"
    ;;
    decr | incr)
        if [ -z "$KEY" ]; then
            memcached_error "You must specify a key to $COMMAND"
        fi
        if [ -z "$VALUE" ]; then
            VALUE="$(cat -)"
        fi
        memcached_6 "$COMMAND" "$KEY" "$VALUE" "$NOREPLY" "$HOST" "$PORT"
    ;;
    delete)
        if [ -z "$KEY" ]; then
            memcached_error "You must specify a key to $COMMAND"
        fi
        memcached_4 "$COMMAND" "$KEY" "$HOST" "$PORT"
    ;;
    get)
        if [ -z "$KEY" ]; then
            memcached_error "You must specify a key to $COMMAND"
        fi
        memcached_4 "$COMMAND" "$KEY" "$HOST" "$PORT" | sed -e '1 d' -e '$ d'
    ;;
    stats)
        memcached_4 "$COMMAND" "$KEY" "$HOST" "$PORT" | sed -e '$ d'
    ;;
    list)
        memcached_4 stats items "$HOST" "$PORT" | sed -e '$ d' | sed -n '/:number/p' | sed -e 's/STAT items://' -e 's/:number//' | memcached_cachedump "$HOST" "$PORT"
    ;;
    touch)
        if [ -z "$KEY" ]; then
            memcached_error "You must specify a key to $COMMAND"
        fi
        memcached_5 "$COMMAND" "$KEY" "$EXPTIME" "$HOST" "$PORT"
    ;;
    *) memcached_error "Invalid command to execute" ;;
esac

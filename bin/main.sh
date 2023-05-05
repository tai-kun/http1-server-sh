#!/bin/bash

set -e

# shellcheck disable=SC1091
source /etc/serversh/bin/utils.sh

function resp_405() {
    _resp_xxx 405 'Method Not Allowed'
}

function resp_500() {
    _resp_xxx 500 'Internal Server Error'
}

function resp_505() {
    _resp_xxx 505 'HTTP Version Not Supported'
}

read -r -t 1 line || resp_400

# $line is like "GET / HTTP/1.1"
REQ_METHOD="$(echo "$line" | cut -d' ' -f1 | tr -d '\r' -d '\n')"
URL_PATH="$(  echo "$line" | cut -d' ' -f2 | tr -d '\r' -d '\n')"
HTTP_VER="$(  echo "$line" | cut -d' ' -f3 | tr -d '\r' -d '\n')"

log debug "REQ_METHOD=$REQ_METHOD"
log debug "URL_PATH=$URL_PATH"
log debug "HTTP_VER=$HTTP_VER"

_RESP_HTTP_VER="$HTTP_VER"

[[ "$REQ_METHOD" == 'GET' ]] || resp_405
[[ "$HTTP_VER" == 'HTTP/1.0' || "$HTTP_VER" == 'HTTP/1.1' ]] || resp_505

URL_PATHNAME="$(echo -n "$URL_PATH" | awk -F '?' '{ print $1 }' | sed -e 's#//*#/#g')"
URL_SEARCH="$(  echo -n "$URL_PATH" | awk -F '?' '{ print $2 }' | sed -e 's#//*$##')"

log debug "URL_PATHNAME=$URL_PATHNAME"
log debug "URL_SEARCH=$URL_SEARCH"
log debug "Exec: $SERVERSH_MAIN_SCRIPT"

RESP="$(
    env _RESP_HTTP_VER="$_RESP_HTTP_VER" \
    /bin/bash "$SERVERSH_MAIN_SCRIPT" "$URL_PATHNAME" "$URL_SEARCH"
)" || {
    log error "Exit code: $?"

    if [[ -n "$RESP" ]]; then
        log "$RESP"
    fi

    resp_500
}

echo -n "$RESP"

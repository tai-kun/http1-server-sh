#!/bin/bash

set -e

# shellcheck source=/dev/null
source /etc/serversh/bin/env.sh

function _to_log_level_num() {
    case "$1" in
        'error')   echo 40;;
        'warn')    echo 30;;
        'info')    echo 20;;
        'debug')   echo 10;;
        *)         echo  0;;
    esac
}

LOG_LEVEL_NUM=$(_to_log_level_num "$SERVERSH_LOG_LEVEL")

function log() {
    local TIMESTAMP
    local RAW_LABEL

    if [[ "$#" -lt 2 ]]; then
        echo "$1" >> "$SERVERSH_LOG_FILE" || true

        return 0
    fi

    if [[ $(_to_log_level_num "${1,,}") -lt "$LOG_LEVEL_NUM" ]]; then
        return 0
    fi

    TIMESTAMP="$(date '+%Y-%m-%dT%H:%M:%S')Z"
    RAW_LABEL="$TIMESTAMP $(printf '%-5s\n' "${1^^}")"

    shift

    echo "$RAW_LABEL $*" >> "$SERVERSH_LOG_FILE" || true
}

function get_query_value_from_search() {
    local SEARCH
    local QUERY
    local VALUE
    SEARCH="$1"
    QUERY="$2"
    # shellcheck disable=SC2001
    VALUE="$(echo "$SEARCH" | sed -e 's#.*'"$QUERY"'=\([^&]*\).*#\1#')"

    if [[ "$VALUE" == "$SEARCH" ]]; then
        printf '%s' "${3:-}" # default value
    else
        printf '%b' "${VALUE//%/\\x}"
    fi
}

_RESP_HTTP_VER="${_RESP_HTTP_VER:-HTTP/1.1}"

function _resp_xxx() {
    local CODE
    local TEXT
    local DATA
    CODE="$1"
    TEXT="$2"
    DATA="${3:-}"

    log debug "$_RESP_HTTP_VER $CODE $TEXT"

    echo "$_RESP_HTTP_VER $CODE $TEXT"
    echo 'Content-Type: text/plain'
    echo "Content-Length: $(echo -n "$DATA" | wc -c)"
    echo ''
    echo -n "$DATA"

    exit 0
}

function resp_200() {
    _resp_xxx 200 'OK' "${1:-}"
}

function resp_400() {
    _resp_xxx 400 'Bad Request' "${1:-}"
}

function resp_404() {
    _resp_xxx 404 'Not Found' "${1:-}"
}

function resp_json() {
    local DATA
    DATA="$1"

    log debug "$_RESP_HTTP_VER 200 OK"

    echo "$_RESP_HTTP_VER 200 OK"
    echo 'Content-Type: application/json'
    echo "Content-Length: $(echo -n "$DATA" | wc -c)"
    echo ''
    echo -n "$DATA"

    exit 0
}

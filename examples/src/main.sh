#!/bin/bash

set -e

# shellcheck disable=SC1091
source /etc/serversh/bin/utils.sh

ROUTE="$1"
SEARCH="$2"

function param() {
    get_query_value_from_search "$SEARCH" "$1" "${2:-}"
}

param1=$(param 'param1' 0)

[[ "$param1" =~ ^[0-9]*$ ]] || {
    log error "400 Bad Request, $ROUTE, param1=$param1"
    resp_400 'param1 must be a number'
}

log info "200 OK, $ROUTE, param1=$param1"
resp_200 'Success'

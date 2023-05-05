#!/bin/bash

set -e

# shellcheck disable=SC1091
source /etc/serversh/bin/utils.sh

if [[ -f "$SERVERSH_INIT_SCRIPT" ]]; then
    log info "Exec: $SERVERSH_INIT_SCRIPT"

    OUT="$(/bin/bash "$SERVERSH_INIT_SCRIPT")" || {
        EXIT_CODE="$?"

        log error "Exit code: $EXIT_CODE"

        if [[ -n "$OUT" ]]; then
            log "$OUT"
        fi

        exit $EXIT_CODE
    }
fi

log info "Listening on port $SERVERSH_PORT_NUMBER"

socat \
    TCP-LISTEN:"$SERVERSH_PORT_NUMBER,fork,reuseaddr" \
    SYSTEM:"/bin/bash /etc/serversh/bin/main.sh"

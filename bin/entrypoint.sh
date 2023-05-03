#!/bin/bash

set -e

# shellcheck disable=SC1091
source /etc/serversh/bin/utils.sh

if [[ -f "$SERVERSH_INIT_SCRIPT" ]]; then
    log debug "Exec: $SERVERSH_INIT_SCRIPT"

    /bin/bash "$SERVERSH_INIT_SCRIPT"
fi

log info "Listening on port $SERVERSH_PORT_NUMBER"

socat \
    TCP-LISTEN:"$SERVERSH_PORT_NUMBER,fork,reuseaddr" \
    SYSTEM:"/bin/bash /etc/serversh/bin/main.sh"

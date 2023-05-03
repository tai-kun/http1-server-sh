#!/bin/bash

set -e

SERVERSH_LOG_LEVEL="${SERVERSH_LOG_LEVEL:-info}"
export SERVERSH_LOG_LEVEL="${SERVERSH_LOG_LEVEL,,}"
export SERVERSH_LOG_FILE="${SERVERSH_LOG_FILE:-/var/log/serversh.log}"
export SERVERSH_INIT_SCRIPT="${SERVERSH_INIT_SCRIPT:-/etc/serversh/src/init.sh}"
export SERVERSH_MAIN_SCRIPT="${SERVERSH_MAIN_SCRIPT:-/etc/serversh/src/main.sh}"
export SERVERSH_PORT_NUMBER="${SERVERSH_PORT_NUMBER:-2980}"

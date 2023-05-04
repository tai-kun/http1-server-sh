#!/usr/bin/env bash

set -e

if [[ "${1:-}" == 'dev' ]]; then
    docker buildx build \
        --tag ghcr.io/tai-kun/http1-server-sh:latest \
        .
fi

docker run --rm -it -p 2980:2980 -e SERVERSH_LOG_LEVEL=debug \
    -v "$(pwd)/examples/log:/var/log" \
    -v "$(pwd)/examples/src:/etc/serversh/src" \
    ghcr.io/tai-kun/http1-server-sh:latest

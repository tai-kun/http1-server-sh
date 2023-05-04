#!/usr/bin/env bash

set -e

function download() {
    local DST
    local SRC
    DST="$1"
    SRC="$2"

    mkdir -p "$(dirname "$DST")"

    echo "Downloading $SRC to $DST"

    if ! curl -f -sS -Lo "$DST" "$SRC"; then
        return 1
    fi

    echo 'Done'
}

function download_once() {
    local DST
    local SRC
    DST="$1"
    SRC="$2"

    if [[ ! -f "$DST" ]]; then
        download "$DST" "$SRC"
    fi
}

KUBECTL="$(which kubectl || echo "$(pwd)/examples/.cache/kubectl")"
KIND="$(which kind || echo "$(pwd)/examples/.cache/kind")"

download_once "$KUBECTL" https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
download_once "$KIND"    https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64

chmod +x "$KUBECTL"
chmod +x "$KIND"

"$KIND" create cluster --name example --config <(cat <<EOF
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
    - role: control-plane
    - role: worker
EOF
)

"$KUBECTL" apply -f "$(pwd)/examples/k8s.yaml"

while [[ "$("$KUBECTL" get pods -l app=get-pod-info -o jsonpath='{.items[0].status.phase}')" != 'Running' ]]; do
    sleep 1
done

echo ''
echo 'Try:'
echo '  curl localhost:2980/ip?name=target-pod'
echo '  curl localhost:2980/log'
echo ''

"$KUBECTL" port-forward service/get-pod-info 2980:80 &
KUBECTL_PID=$!

function _kill() {
    echo ''

    "$KIND" delete cluster --name example

    wait $KUBECTL_PID
}

trap _kill SIGINT

echo 'Press Ctrl+C to stop'
echo ''

wait $KUBECTL_PID

_kill

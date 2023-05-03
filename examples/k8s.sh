#!/usr/bin/env bash

set -e

kubectl apply -f k8s.yaml

echo 'Please wait 5 seconds'

sleep 5

echo 'Try:'
echo '  curl localhost:2980/ip?name=target-pod'
echo '  curl localhost:2980/log'
echo ''

kubectl port-forward service/get-pod-info 2980:80

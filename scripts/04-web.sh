#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
kubectl apply -f manifests/05-web.yaml
kubectl -n three-tier rollout status deployment/web --timeout=300s

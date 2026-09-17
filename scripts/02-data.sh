#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
kubectl apply -f manifests/02-mariadb.yaml
kubectl apply -f manifests/03-redis.yaml
kubectl -n three-tier rollout status statefulset/mariadb --timeout=600s
kubectl -n three-tier rollout status statefulset/redis --timeout=300s
kubectl -n three-tier get pvc

#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo podman build --network=host -t "$WAS_IMAGE" -f was/Containerfile was
mkdir -p build rendered
sudo podman save --format docker-archive "$WAS_IMAGE" > build/was-image.tar
sudo ctr -n k8s.io images import build/was-image.tar
envsubst '$WAS_IMAGE' < manifests/04-was.yaml > rendered/04-was.yaml
kubectl apply -f rendered/04-was.yaml
kubectl -n three-tier rollout status deployment/was --timeout=600s

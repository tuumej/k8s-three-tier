#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
kubectl -n envoy-gateway-system get pods -l gateway.envoyproxy.io/owning-gateway-name=app-gateway --show-labels
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl apply -f manifests/07-network-policy.yaml
kubectl -n three-tier get networkpolicy

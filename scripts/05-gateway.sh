#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
mkdir -p vendor certs
curl -fL --retry 3 "https://github.com/envoyproxy/gateway/releases/download/${ENVOY_VERSION}/install.yaml" -o vendor/envoy-install.yaml
kubectl apply --server-side -f vendor/envoy-install.yaml
kubectl -n envoy-gateway-system wait --for=condition=Available deployment/envoy-gateway --timeout=300s
if ! kubectl -n three-tier get secret app-tls >/dev/null 2>&1; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 90 -keyout certs/tls.key -out certs/tls.crt -subj '/CN=three-tier-lab' -addext "subjectAltName=IP:${NODE_IP},DNS:app.test"
  kubectl -n three-tier create secret tls app-tls --cert=certs/tls.crt --key=certs/tls.key
fi
kubectl apply -f manifests/06-gateway.yaml
kubectl -n three-tier get gateway,httproute
kubectl -n envoy-gateway-system get svc,pods

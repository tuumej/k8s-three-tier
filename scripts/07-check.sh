#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
kubectl -n three-tier get pods,svc,pvc
kubectl -n three-tier get gateway,httproute
ENVOY_SERVICE=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-namespace=three-tier,gateway.envoyproxy.io/owning-gateway-name=app-gateway -o jsonpath='{.items[0].metadata.name}')
HTTPS_PORT=$(kubectl -n envoy-gateway-system get svc "$ENVOY_SERVICE" -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
printf 'HTTPS URL: https://%s:%s\n' "$NODE_IP" "$HTTPS_PORT"
printf 'Use only this NodePort in the ACG, restricted to your VPN/admin source.\n'
test -s certs/tls.crt || { echo 'Use a CA certificate appropriate for your installed app-tls certificate.'; exit 1; }
curl --fail --show-error --connect-timeout 5 --max-time 15 --cacert certs/tls.crt "https://${NODE_IP}:${HTTPS_PORT}/"
curl --fail --show-error --connect-timeout 5 --max-time 15 --cacert certs/tls.crt "https://${NODE_IP}:${HTTPS_PORT}/api/hello"
printf '\n'
curl --fail --show-error --connect-timeout 5 --max-time 15 --cacert certs/tls.crt "https://${NODE_IP}:${HTTPS_PORT}/api/hello"
printf '\n'

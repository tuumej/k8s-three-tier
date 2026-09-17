#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
kubectl get node "$NODE_NAME"
node_host_label=$(kubectl get node "$NODE_NAME" -o jsonpath='{.metadata.labels.kubernetes\.io/hostname}')
[[ "$node_host_label" == "$NODE_NAME" ]] || { echo "NODE_NAME and hostname label differ; adjust PV nodeAffinity before applying."; exit 1; }
kubectl wait --for=condition=Ready "node/$NODE_NAME" --timeout=60s
kubectl get pods -n kube-system
[[ "$DATA_DIR" == /* && "$DATA_DIR" != / ]] || { echo "Use an absolute dedicated DATA_DIR"; exit 1; }
sudo mkdir -p "$DATA_DIR/mariadb" "$DATA_DIR/redis"
sudo chmod 750 "$DATA_DIR" "$DATA_DIR/mariadb" "$DATA_DIR/redis"
kubectl apply -f manifests/00-namespace.yaml
mkdir -p rendered
envsubst '$NODE_NAME $DATA_DIR' < manifests/01-storage.yaml > rendered/01-storage.yaml
kubectl apply -f rendered/01-storage.yaml
if ! kubectl -n three-tier get secret mariadb-auth >/dev/null 2>&1; then
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT
  openssl rand -hex 32 | tr -d '\n' > "$temp_dir/root-password"
  openssl rand -hex 32 | tr -d '\n' > "$temp_dir/password"
  kubectl -n three-tier create secret generic mariadb-auth --from-file="$temp_dir/root-password" --from-file="$temp_dir/password"
  rm -rf "$temp_dir"
  trap - EXIT
fi
if ! kubectl -n three-tier get secret redis-auth >/dev/null 2>&1; then
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT
  openssl rand -hex 32 | tr -d '\n' > "$temp_dir/password"
  kubectl -n three-tier create secret generic redis-auth --from-file="$temp_dir/password"
  rm -rf "$temp_dir"
  trap - EXIT
fi
kubectl get pv

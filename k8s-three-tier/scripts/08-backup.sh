#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
mkdir -p backups
backup_file="backups/appdb-$(date -u +%Y%m%dT%H%M%SZ).sql.gz"
trap 'rm -f "$backup_file.partial"' EXIT
kubectl -n three-tier exec mariadb-0 -- sh -ec 'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb-dump -uroot --single-transaction --routines --events --triggers --databases appdb' | gzip > "$backup_file.partial"
gzip -t "$backup_file.partial"
mv "$backup_file.partial" "$backup_file"
sha256sum "$backup_file" > "$backup_file.sha256"
printf 'Backup completed: %s\n' "$backup_file"

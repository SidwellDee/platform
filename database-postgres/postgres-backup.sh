#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=postgres_postgres-1" --format "{{.Names}}")
PG_USER="postgres"
PG_PASSWORD="instant101"
OUTPUT_DIR="/home/$USER/eswatini_hie/backups/pgsql"
DATE=$(date +%Y%m%d_%H%M%S)

DATABASES=("audit_db" "hapi" "kc_test_db" "keycloak" "notifications_db" "postgres" "repmgr" "superset" "users_db")

mkdir -p "$OUTPUT_DIR/$DATE"

for DB in "${DATABASES[@]}"; do
    OUTPUT_FILE="${OUTPUT_DIR}/$DATE/${DB}_${DATE}.tar"
    echo "Backing up database: $DB to $OUTPUT_FILE"
    docker exec -i "$CONTAINER_NAME" bash -c "PGPASSWORD='$PG_PASSWORD' pg_dump --data-only -U $PG_USER -F t $DB" > "$OUTPUT_FILE"
done

echo "Backup completed for all databases."

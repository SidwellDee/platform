#!/bin/bash

CONTAINER_NAME="d6e6e572b6b2"
PG_USER="postgres"
PG_PASSWORD="instant101"
OUTPUT_DIR="/home/pg_basebackups"
#DATE=$(date +%Y%m%d_%H%M%S)
DATE=$(date +%Y%m%d)

DATABASES=("audit_db" "hapi" "kc_test_db" "keycloak" "mpi_db" "notifications_db" "postgres" "repmgr" "superset" "users_db")

mkdir -p "$OUTPUT_DIR/$DATE"

for DB in "${DATABASES[@]}"; do
    OUTPUT_FILE="${OUTPUT_DIR}/$DATE/${DB}_${DATE}.tar"
    echo "Backing up database: $DB to $OUTPUT_FILE"
    docker exec -i "$CONTAINER_NAME" bash -c "PGPASSWORD='$PG_PASSWORD' pg_dump -U $PG_USER -F t $DB" > "$OUTPUT_FILE"
done

echo "Backup completed for all databases."

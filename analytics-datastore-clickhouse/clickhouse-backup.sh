#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=clickhouse_analytics-datastore-clickhouse" --format "{{.Names}}")

if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: ClickHouse container not found. Please ensure it's running and the name is correct."
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)
DATABASES=("default")

for DB in "${DATABASES[@]}"; do
    echo "Backing up database: $DB"

    docker exec "$CONTAINER_NAME" clickhouse-client --query="BACKUP DATABASE ${DB} TO Disk('backups', '${DB}_${DATE}.zip');"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to restore database '$DB'."
        exit 2
    else
        echo "Successfully restored database '$DB'."
    fi
done

echo "ClickHouse backup complete."

#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=clickhouse_analytics-datastore-clickhouse" --format "{{.Names}}")

if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: ClickHouse container not found. Please ensure it's running and the name is correct."
    exit 1
fi

DATABASES=("default")

#backup folder
BACKUP_TIMESTAMP="20251111_104642"

for DB in "${DATABASES[@]}"; do
    echo "Restoring database: $DB"

    docker exec "$CONTAINER_NAME" clickhouse-client --query="RESTORE DATABASE ${DB} FROM Disk('backups', '${DB}_${BACKUP_TIMESTAMP}/');"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to restore database '$DB'."
        exit 2
    else
        echo "Successfully restored database '$DB'."
    fi

done

echo "ClickHouse restore complete."

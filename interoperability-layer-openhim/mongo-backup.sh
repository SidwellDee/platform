#!/bin/bash

# Configuration
SERVICE_NAME="mongodb_service"       # Name of the MongoDB service in Docker Swarm
CONTAINER_NAME=$(docker ps --filter "name=${SERVICE_NAME}" --format "{{.Names}}" | head -n 1)
BACKUP_DIR="/var/backups/mongodb"    # Host directory to store backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="mongo_backup_$TIMESTAMP"
MONGO_DB_NAME="your_db_name"         # Replace with your actual DB name

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Run mongodump inside the container
echo "Starting MongoDB backup from container: $CONTAINER_NAME"
docker exec "$CONTAINER_NAME" sh -c "mongodump --db $MONGO_DB_NAME --archive" > "$BACKUP_DIR/$BACKUP_NAME.archive"

# Verify backup
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_DIR/$BACKUP_NAME.archive"
else
    echo "Backup failed"
    exit 1
fi

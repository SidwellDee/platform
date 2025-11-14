#!/bin/bash

# Configuration
SERVICE_NAME="openhim_mongo-1"       
CONTAINER_NAME=$(docker ps --filter "name=${SERVICE_NAME}" --format "{{.Names}}" | head -n 1)
BACKUP_DIR="/home/sidwelldlamini/eswatini_hie/backups/mongo"    
MONGO_DB_NAME="openhim"
BACKUP_FILE="$1"

# Validate input
if [ -z "$BACKUP_FILE" ]; then
    echo "Please provide the backup file name as an argument."
    echo "Usage: ./restore_mongo.sh <backup_file.archive>"
    exit 1
fi

# Check if backup file exists
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_DIR/$BACKUP_FILE"
    exit 1
fi

# Restore using mongorestore inside the container
echo "Starting MongoDB restore into container: $CONTAINER_NAME"
cat "$BACKUP_DIR/$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" sh -c "mongorestore --db $MONGO_DB_NAME --archive"

# Verify restore
if [ $? -eq 0 ]; then
    echo "✅ Restore successful from $BACKUP_FILE"
else
    echo "❌ Restore failed"
    exit 1
fi

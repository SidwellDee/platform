#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=postgres_postgres-1" --format "{{.Names}}")
PG_USER="postgres"
PG_PASSWORD="instant101"
DATE="20251113_145122"

DATABASES=("audit_db" "hapi" "kc_test_db" "keycloak" "notifications_db" "postgres" "repmgr" "superset" "users_db")

BACKUPS=("audit_db_$DATE.tar" 
    "hapi_$DATE.tar" 
    "kc_test_db_$DATE.tar" 
    "keycloak_$DATE.tar" 
    "mpi_db_$DATE.tar" 
    "notifications_db_$DATE.tar" 
    "postgres_$DATE.tar" 
    "repmgr_$DATE.tar" 
    "superset_$DATE.tar"
    "users_db_$DATE.tar")

for i in "${!DATABASES[@]}"; do
    DB_NAME="${DATABASES[$i]}"
    BACKUP_FILE="${BACKUPS[$i]}"
    
    echo "Restoring $DB_NAME from $BACKUP_FILE..."

    docker exec -i "$CONTAINER_NAME" bash -c "PGPASSWORD='$PG_PASSWORD' pg_restore --clean --if-exists --verbose -U $PG_USER -d $DB_NAME /var/backups/$DATE/$BACKUP_FILE"

    echo "Finished restoring $DB_NAME"
done

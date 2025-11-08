#!/bin/bash

#==========================================================================
# IMPORT DGRAPH DATA
#==========================================================================

docker stack deploy -c docker-compose.dgraph-restore.yml jempi-restore

sleep 30

#==========================================================================
# CLEANUP DGFRPH RESTORE TEMP
#==========================================================================

docker stack rm jempi-restore
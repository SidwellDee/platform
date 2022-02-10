#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    if  [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose-mongo.yml instant

        # Set up the replica set
        "$composeFilePath"/initiateReplicaSet.sh

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

        echo "Sleep 60 seconds to give OpenHIM Core and Postgres time to start up before OpenHIM Console and HAPI-FHIR run"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose-mongo.yml -c "$composeFilePath"/docker-compose-mongo.prod.yml instant

        # Set up the replica set
        "$composeFilePath"/initiateReplicaSet.sh

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

        echo "Sleep 60 seconds to give OpenHIM Core and Postgres time to start up before OpenHIM Console and HAPI-FHIR run"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    fi

    echo "Sleep 60 seconds to give HAPI-FHIR and OpenHIM Console time to start up"
    sleep 60

    docker stack deploy -c "$composeFilePath"/importer/docker-compose.config.yml instant

    echo "Sleep 60 seconds to give core config importer time to run before cleaning up service"
    sleep 60

    docker service rm instant_core-config-importer
elif [ "$1" == "up" ]; then
    if [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml -c "$composeFilePath"/docker-compose.mongo.dev.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    fi 
elif [ "$1" == "down" ]; then
    docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_hapi-proxy=0 instant_mongo-1=0 instant_mongo-2=0 instant_mongo-3=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_openhim-core instant_openhim-console instant_hapi-proxy instant_mongo-1 instant_mongo-2 instant_mongo-3

    echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
    sleep 10

    docker volume rm instant_openhim-mongo1 instant_openhim-mongo2 instant_openhim-mongo3
    docker config rm instant_console.config
else
    echo "Valid options are: init, up, down, or destroy"
fi
#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="kafka"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"
  if [[ -n $STACK_NAME ]]; then
    STACK=$STACK_NAME
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local kafka_dev_compose_filename=""
  local kafka_cluster_compose_filename=""
  local kafka_utils_dev_compose_filename=""
  local kafka_zoo_cluster_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    kafka_dev_compose_filename="docker-compose.dev.kafka.yml"
    kafka_utils_dev_compose_filename="docker-compose.dev.kafka-utils.yml"
  else
    log info "Running package in PROD mode"
  fi

  if [[ $CLUSTERED_MODE == "true" ]]; then
    kafka_zoo_cluster_compose_filename="docker-compose.cluster.kafka-zoo.yml"
    kafka_cluster_compose_filename="docker-compose.cluster.kafka.yml"
  fi

  (
    log info "Deploy Zookeeper"

    docker::deploy_service "$STACK" "${COMPOSE_FILE_PATH}" "docker-compose.kafka-zoo.yml" "$kafka_zoo_cluster_compose_filename"

    log info "Deploy Kafka"

    docker::deploy_service "$STACK" "${COMPOSE_FILE_PATH}" "docker-compose.kafka.yml" "$kafka_cluster_compose_filename" "$kafka_dev_compose_filename"
    config::await_service_reachable "kafka" "$STACK" "Connected"

    log info "Deploy the other services dependent of Kafka"

    docker::deploy_service "$STACK" "${COMPOSE_FILE_PATH}" "docker-compose.kafka-utils.yml" "$kafka_utils_dev_compose_filename"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  log info "Await Kafka to be running and responding"
  config::await_service_running "kafka" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFKA_INSTANCES}" "$STACK"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "message-bus-kafka-config-importer" "kafka" "$STACK"
}

function destroy_package() {
  docker::stack_destroy "$STACK"

  docker::try_remove_volume $STACK zookeeper-1-volume kafka-volume

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  fi

  docker::prune_configs "kafka"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running package in Cluster node mode"
    else
      log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services "$STACK" 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"

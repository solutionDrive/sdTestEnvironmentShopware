#!/usr/bin/env bash

SHOPWARE_VERSION=$2

# Remove Shopware-Version from `$@`, so it is not passed to docker-compose command
for arg do
  shift
  case $arg in
    (52|53|54|55|56|57) : ;;
       (*) set -- "$@" "$arg" ;;

  esac
done


if [ -z "${SHOPWARE_VERSION}" ]; then
    echo "You must provide the version of shopware you want to interact with, e.g. 54 for shopware 5.4"
    exit 1
fi

# directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d ${DIR}/../vendor/solutiondrive/sd-test-environment-shopware ]; then
    PACKAGE_DIR="$( dirname "${DIR}" )"/vendor/solutiondrive/sd-test-environment-shopware
elif [ -d ${DIR}/../solutiondrive/sd-test-environment-shopware ]; then
    PACKAGE_DIR="$( cd "$( dirname "${DIR}" )"/solutiondrive/sd-test-environment-shopware && pwd )"
elif [ -d ${DIR}/../../../solutiondrive/sd-test-environment-shopware ]; then
    PACKAGE_DIR="$( dirname "${DIR}" )"
fi

if [ "$PACKAGE_DIR" == "" ]; then
    echo "Could not find package directory! For testing purposes we will use '.'"
    PACKAGE_DIR=.
fi

if [ ! -d ${PACKAGE_DIR} ]; then
    echo "Could not find package directory of sd-test-environment-shopware. Did you move the bin directory?"
    exit 1
fi

export PROJECT_DIR="$( dirname $( dirname $( dirname "${PACKAGE_DIR}") ) )"
export PACKAGE_DIR="${PACKAGE_DIR}"
export PROJECT_NAME="$( basename ${PROJECT_DIR} | tr '[:upper:]' '[:lower:]' )"
export DOCKER_COMPOSE_YAML=${PROJECT_DIR}"/etc/test/docker-compose${SHOPWARE_VERSION}.yml"

if [ "$1" != "init" ]; then
    source ${PACKAGE_DIR}/etc/scripts/checkSdTestEnvironment.sh ${SHOPWARE_VERSION}
fi


function prepare {
    if [ "$PROJECT_NAME" == "." ]; then
        echo "PROJECT_NAME cannot be '.' only. Setting it to 'testenvironmentshopware'"
        export PROJECT_NAME=testenvironmentshopware
    fi
}

function echo_configuration {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Running (web)server on ports:"
    echo "PHP 7.2: ${SHOPWARE_VERSION}872"
    echo "PHP 7.1: ${SHOPWARE_VERSION}871"
    echo "PHP 7.0: ${SHOPWARE_VERSION}870"
    echo "PHP 5.6: ${SHOPWARE_VERSION}856"
    echo "MySQL:   ${SHOPWARE_VERSION}331"
    echo "Mailhog: 80${SHOPWARE_VERSION}"
    echo ""
    echo "PROJECT_DIR: ${PROJECT_DIR}"
    echo "PROJECT_NAME: ${PROJECT_NAME}"
    echo "PACKAGE_DIR: ${PACKAGE_DIR}"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

function init_environment {
    echo "Prepare directories"
    mkdir -p ${PROJECT_DIR}/etc/test
    mkdir -p ${PROJECT_DIR}/etc/test/nginx
    mkdir -p ${PROJECT_DIR}/etc/test/nginx/conf.d
    mkdir -p ${PROJECT_DIR}/etc/test/php

    echo "Copying testing README"
    cp ${PACKAGE_DIR}/README.md ${PROJECT_DIR}/README.TESTING.md

    echo "Copying docker-compose.yml to be able to easily modify it for special needs"
    cp ${PACKAGE_DIR}/docker-compose${SHOPWARE_VERSION}.yml ${PROJECT_DIR}/etc/test/docker-compose${SHOPWARE_VERSION}.yml

    echo "Copying config files to be able to easily modify it for special needs"
    cp ${PACKAGE_DIR}/php/* ${PROJECT_DIR}/etc/test/php
    cp -R ${PACKAGE_DIR}/nginx/* ${PROJECT_DIR}/etc/test/nginx

    echo "You can find additional information in the testing README, see 'README.TESTING.md'"
}

function build_container {
    prepare
    docker_compose_cmd build $@
}

function run_container {
    prepare
    echo_configuration
    docker_compose_cmd up $@
}

function start_container {
    prepare
    echo_configuration
    docker_compose_cmd up --no-start --remove-orphans $@
    docker_compose_cmd start $@
}

function stop_container {
    docker_compose_cmd stop $@
}

function restart_container {
    stop_container $@
    start_container $@
}


function remove_container {
    docker_compose_cmd down -v
    docker_compose_cmd rm -v $@
}

function pull_container {
    docker_compose_cmd pull $@
}

function get_logs {
    docker_compose_cmd logs $@
}

function reset_container {
    remove_container -s -f $@
    start_container $@
}

function docker_compose_cmd {
    docker-compose \
        -f ${DOCKER_COMPOSE_YAML} \
        -p ${PROJECT_NAME} \
        $@
}


## start of the real program

export PROJECT_DIR
export PROJECT_NAME

case "$1" in
    init)
        shift
        init_environment $@
        ;;
    build)
        shift
        build_container $@
        ;;
    run)
        shift
        run_container $@
        ;;
    start)
        shift
        start_container $@
        ;;
    stop)
        shift
        stop_container $@
        ;;
    restart)
        shift
        restart_container $@
        ;;
    reset)
        shift
        reset_container $@
        ;;
    remove|rm)
        shift
        remove_container $@
        ;;
    pull)
        shift
        pull_container $@
        ;;
    log|logs)
        shift
        get_logs $@
        ;;
    *)
        echo "usage: init/start/stop/run/restart/build/reset/remove/pull/logs <Shopware-Version, e.g. 54 for shopware 5.4>"
        ;;
esac

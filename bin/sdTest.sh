#!/usr/bin/env bash

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
export PROJECT_NAME="$( basename ${PROJECT_DIR} | tr '[:upper:]' '[:lower:]' )"
export DOCKER_COMPOSE_YAML=${PROJECT_DIR}"/etc/test/docker-compose.yml"

if [ "$1" != "init" ]; then
    source ${PACKAGE_DIR}/etc/scripts/checkSdTestEnvironment.sh
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
    echo "PHP 7.2: 10872"
    echo "PHP 7.1: 10871"
    echo "PHP 7.0: 10870"
    echo "PHP 5.6: 10856"
    echo "MySQL:   10331"
    echo ""
    echo "PROJECT_DIR: ${PROJECT_DIR}"
    echo "PROJECT_NAME: ${PROJECT_NAME}"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

function init_environment {
    echo "Prepare directories"
    mkdir -p ${PROJECT_DIR}/etc/test

    echo "Copying testing README"
    cp ${PACKAGE_DIR}/README.md ${PROJECT_DIR}/README.TESTING.md

    echo "Copying docker-compose.yml to be able to easily modify it for special needs"
    cp ${PACKAGE_DIR}/docker-compose.yml ${PROJECT_DIR}/etc/test/docker-compose.yml

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
    docker_compose_cmd up --no-start $@
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
    log|logs)
        shift
        get_logs $@
        ;;
    *)
        echo "usage: start/stop/run/restart/build/reset/remove/logs"
        ;;
esac

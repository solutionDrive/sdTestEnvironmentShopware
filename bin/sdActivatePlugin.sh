#!/usr/bin/env bash
VERSION=$1

if [ -z "${VERSION}" ]; then
    echo "You must give a version to execute command on, for example 71 for PHP 7.1 container."
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

if [ ! -d ${PACKAGE_DIR} ]; then
    echo "Could not find package directory of sd-test-environment-shopware. Did you move the bin directory?"
    exit 1
fi

PROJECT_DIR="$( dirname $( dirname $( dirname "${PACKAGE_DIR}") ) )"
PROJECT_NAME="$( basename ${PROJECT_DIR} | tr '[:upper:]' '[:lower:]' )"
WORK_DIR="/var/www/shopware54_php${VERSION}"

function init_plugin {
    echo "Init plugin $PROJECT_NAME"
    link_plugin
}

function link_plugin {
    echo "Link plugin $PROJECT_NAME"

}

function reset_plugin {
    echo "reset plugin"
}

## start of the real program

export PROJECT_DIR
export PROJECT_NAME

case "$2" in
    init)
        shift
        init_plugin $@
        ;;
    reset)
        shift
        reset_plugin $@
        ;;
    *)
        echo "usage: init/reset"
        ;;
esac

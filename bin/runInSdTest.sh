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
# TODO: Think about a good solution for a different shopware version
PHP_CONTAINER_NAME="${PROJECT_NAME}_shopware546_php${VERSION}_1"
WORK_DIR=${WORK_DIR:-"/var/www/shopware54_php${VERSION}"}

docker exec --workdir ${WORK_DIR} -it ${PHP_CONTAINER_NAME} ${@:2}

#!/usr/bin/env bash

VERSION=$1
SHOPWARE_VERSION=$2

# Remove Shopware-Version from `$@`, so it is not passed to docker-compose command
for arg do
  shift
  case $arg in
    (52|53|54|55|56) : ;;
       (*) set -- "$@" "$arg" ;;
  esac
done

if [ -z "${SHOPWARE_VERSION}" ]; then
    echo "You must provide the version of shopware you want to interact with, e.g. 54 for shopware 5.4"
    exit 1
fi

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
PHP_CONTAINER_NAME="${PROJECT_NAME}_shopware${SHOPWARE_VERSION}_php${VERSION}_1"
WORK_DIR=${WORK_DIR:-"/var/www/shopware${SHOPWARE_VERSION}_php${VERSION}"}

docker exec --workdir ${WORK_DIR} -it $(docker container ls -f name=${PHP_CONTAINER_NAME} -q) ${@:2}

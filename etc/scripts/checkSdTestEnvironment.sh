#!/usr/bin/env bash

SHOPWARE_VERSION=$1

if [ ! -d ${PROJECT_DIR} ]; then
    echo "Project directory not found in \$PROJECT_DIR. Did you call this script correctly? Cancel."
    exit 1
fi

if [ ! -f ${PROJECT_DIR}/etc/test/docker-compose${SHOPWARE_VERSION}.yml ]; then
    echo "No docker-compose.yml file found under ${PROJECT_DIR}/etc/test/docker-compose${SHOPWARE_VERSION}.yml - Needed for docker setup. Cancel."
    echo "Perhaps forgot to run 'vendor/bin/sdTest.sh init [SHOPWARE_VERSION]'?"
    exit 1
fi

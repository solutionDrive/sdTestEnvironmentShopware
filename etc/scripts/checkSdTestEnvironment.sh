#!/usr/bin/env bash

if [ ! -d ${PROJECT_DIR} ]; then
    echo "Project directory not found in \$PROJECT_DIR. Did you call this script correctly? Cancel."
    exit 1
fi

if [ ! -f ${PROJECT_DIR}/etc/test/docker-compose.yml ]; then
    echo "No docker-compose.yml file found under ${PROJECT_DIR}/etc/test/docker-compose.yml - Needed for docker setup. Cancel."
    echo "Perhaps forget to run 'vendor/bin/sdTest.sh init'?"
    exit 1
fi

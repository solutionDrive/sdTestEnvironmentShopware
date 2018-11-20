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
PHP_CONTAINER_NAME="${PROJECT_NAME}_shopware54_php${VERSION}_1"
WORK_DIR="/var/www/shopware54_php${VERSION}"

PLUGIN_NAME=$(find . -name '*.php' -maxdepth 1 |sed 's#.*/##' | sed 's/\.php$//1')

PLUGIN_DIRECTORY="custom/plugins/$PLUGIN_NAME"

function add_plugin {
    echo "Init plugin $PLUGIN_NAME"
    link_plugin
    install_plugin
    activate_plugin
}

function link_plugin {
    echo "Link plugin $PROJECT_NAME to $PLUGIN_DIRECTORY"
    execute_in_docker "ln -s /opt/host $PLUGIN_DIRECTORY"
}

function install_plugin {
    execute_in_docker "bin/console sw:plugin:refresh"
    execute_in_docker "bin/console sw:plugin:install $PLUGIN_NAME"
}

function activate_plugin {
    execute_in_docker "bin/console sw:plugin:activate $PLUGIN_NAME"
    execute_in_docker "bin/console sw:cache:clear"
}

function deactivate_plugin {
    execute_in_docker "bin/console sw:plugin:deactivate $PLUGIN_NAME"
    execute_in_docker "bin/console sw:cache:clear"
}

function remove_plugin {
    deactivate_plugin
    execute_in_docker "bin/console sw:plugin:uninstall $PLUGIN_NAME"
    execute_in_docker "rm $PLUGIN_DIRECTORY"
}

function execute_in_docker {
    docker exec --workdir ${WORK_DIR} -it $(docker container ls -f name=${PHP_CONTAINER_NAME} -q) $1
}

## start of the real program

export PROJECT_DIR
export PROJECT_NAME

case "$2" in
    add)
        shift
        add_plugin $@
        ;;
    remove)
        shift
        remove_plugin $@
        ;;
    activate)
        shift
        activate_plugin $@
        ;;
    deactivate)
        shift
        deactivate_plugin $@
        ;;
    *)
        echo "usage: <php-version for example 71> add/remove/activate/deactivate"
        ;;
esac

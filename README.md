Docker based Shopware Testing Environment
=========================================

For easier testing with different shopware- and/or php-versions we use a docker based environment.
There are some docker containers providing MySQL, PHP and so on.
The local filesystem is mapped into the containers that need them.

**NOTE on this README**
This file assumes that bin-scripts are installed to ```vendor/bin``` (as composer does by default).
If your changed this behaviour in your ```composer.json```
you have to adjust the commands written in this file accordingly.

Installation
------------

To use the testing environment in a project,
add the following dependency to your project's composer.json's require-dev section:

    "require-dev": {
        "solutiondrive/sd-test-environment-shopware": "*"
    }

Then do a `composer update` or use `composer require --dev` instead. 

To initialize the testing environment simply run the following:

    vendor/bin/sdTest.sh init

This will create some files:

    /README.TESTING.md              # This README.md in your project for other developers
    /etc/test/docker-compose.yml    # A docker-compose file which can be modified for special needs

Usage / First steps
-------------------

First you should start the testing docker containers (see also next section of this README):

    vendor/bin/sdTest.sh start
    
    
Handle plugin
-------------

For all following commands you must pass a php version, e.g. 71 for PHP 7.1 container:

For adding the plugin run:

    vendor/bin/sdPlugin.sh 71 add
    
For removing the plugin run:

    vendor/bin/sdPlugin.sh 71 remove
    
For activating the plugin run:

    vendor/bin/sdPlugin.sh 71 activate    
    
For deactivating the plugin run:

    vendor/bin/sdPlugin.sh 71 deactivate


Controlling the testing environment
-----------------------------------

To start the containers and get back your local shell just run:

    vendor/bin/sdTest.sh start
    
To stop the containers run:

    vendor/bin/sdTest.sh stop

In stopped state the containers data is saved.

To destroy your containers you can run:

    vendor/bin/sdTest.sh remove

To restart your containers without loosing data you can run:

    vendor/bin/sdTest.sh restart


Can can also run the containers in foreground to monitor the log output of the containers:

    vendor/bin/sdTest.sh run

Then you can stop the execution by pressing CTRL+C. The containers will exit cleanly.


If you started the container in background using ```start```, you can view the logs by running:

    vendor/bin/sdTest.sh logs

You can follow the logs (as known from ```tail -f``` or ```tailf```):

    vendor/bin/sdTest.sh logs -f

To connect to the mysql server use ```127.0.0.1``` as host with port (default: 10331) configured in ```etc/test/docker-compose.yml```.


Less frequently needed
----------------------

To force a rebuild of the containers you can run:

    vendor/bin/sdTest.sh build --no-cache

To be sure that you have the latest version of the (base) containers you can force pulling newer images:
    
    vendor/bin/sdTest.sh build --no-cache --pull

To be sure to use the newest containers (not only build based containers):

    vendor/bin/sdTest.sh pull

To destroy and restart your containers in one step without rebuilding images run:

    vendor/bin/sdTest.sh reset

Executing a command in the testing environment
----------------------------------------------

Commands (for example to clear the cache or to run the setup) can be executed inside the container.
You must give a version to execute command on, e.g. 71 for PHP 7.1 container:

    vendor/bin/runInSdTest.sh 71 ./app/install.sh

If you want to you can even get a shell inside the PHP container:

    vendor/bin/runInSdTest.sh 71 /bin/bash

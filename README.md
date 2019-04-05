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

To initialize the testing environment, e.g. for Shopware 5.4.x simply run the following:

    vendor/bin/sdTest.sh init 54

This will create some files:

    /README.TESTING.md              # This README.md in your project for other developers
    /etc/test/docker-compose.yml    # A docker-compose file which can be modified for special needs

Usage / First steps
-------------------

First you should start the testing docker containers (see also next section of this README):

    vendor/bin/sdTest.sh start SHOPWARE_VERSION
    
    
Handle plugin
-------------

For all following commands you must pass a php and shopware version, 
e.g. 71 for PHP 7.1 container and 54 for Shopware 5.4 :

For adding the plugin run:

    vendor/bin/sdPlugin.sh 71 54 add
    
For removing the plugin run:

    vendor/bin/sdPlugin.sh 71 54 remove
    
For activating the plugin run:

    vendor/bin/sdPlugin.sh 71 54 activate    
    
For deactivating the plugin run:

    vendor/bin/sdPlugin.sh 71 54 deactivate


Controlling the testing environment
-----------------------------------

List of SHOPWARE_VERSION:
- 52 -> v5.2.x
- 53 -> v5.3.x
- 54 -> v5.4.x
- 55 -> v5.5.x

To start the containers e.g. with shopware 5.4 and get back your local shell just run:

    vendor/bin/sdTest.sh start 54
    
To stop the containers run:

    vendor/bin/sdTest.sh stop SHOPWARE_VERSION

In stopped state the containers data is saved.

To destroy your containers you can run:

    vendor/bin/sdTest.sh remove SHOPWARE_VERSION

To restart your containers without loosing data you can run:

    vendor/bin/sdTest.sh restart SHOPWARE_VERSION


Can can also run the containers in foreground to monitor the log output of the containers:

    vendor/bin/sdTest.sh run SHOPWARE_VERSION

Then you can stop the execution by pressing CTRL+C. The containers will exit cleanly.


If you started the container in background using ```start```, you can view the logs by running:

    vendor/bin/sdTest.sh logs SHOPWARE_VERSION

You can follow the logs (as known from ```tail -f``` or ```tailf```):

    vendor/bin/sdTest.sh logs SHOPWARE_VERSION -f

To connect to the mysql server use ```127.0.0.1``` as host with port (default: 10331) configured in ```etc/test/docker-compose.yml```.


Less frequently needed
----------------------

To force a rebuild of the containers you can run:

    vendor/bin/sdTest.sh build --no-cache

To be sure that you have the latest version of the (base) containers you can force pulling newer images:
    
    vendor/bin/sdTest.sh build --no-cache --pull

To be sure to use the newest containers (not only build based containers):

    vendor/bin/sdTest.sh pull SHOPWARE_VERSION

To destroy and restart your containers in one step without rebuilding images run:

    vendor/bin/sdTest.sh reset SHOPWARE_VERSION

Executing a command in the testing environment
----------------------------------------------

Commands (for example to clear the cache or to run the setup) can be executed inside the container.
You must give a version of php and shopware to execute command on, e.g. 71 for PHP 7.1 container and 54 for Shopware 5.4.x:

    vendor/bin/sdRunInTest.sh 71 54 ./app/install.sh

If you want to you can even get a shell inside the PHP container:

    vendor/bin/sdRunInTest.sh 71 54 /bin/bash

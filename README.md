2degrees Content Portal
=======================

## Requirements

- PHP 5.4+ / Composer (http://php-osx.liip.ch/ for Marmite OS X users - deal with the image cropping exclusion... thank you Apple )
- NodeJS / NPM / Bower
- Ruby / RubyGems / Bundler

## Setup

### 1. Install / Update Global Dependencies

You need a more recent version of NPM than the one that comes with Node

````bash
sudo npm install -g npm

# OR #

sudo npm update -g npm
````

Install Gulp

````bash
sudo npm install -g gulp
````

Install Mocha

````bash
sudo npm install -g mocha
````

Install Notify Send

````bash
sudo npm install -g notify-send
````

Install Ruby SASS

````bash
sudo gem install sass
````

### 2. Create the `_ss_environment.php` file and related setup

Below are some sample `_ss_environment.php` setups

#### SQLite on PHP inbuilt server

````bash
echo "<?php
define('APPLICATION_ENV', 'development');
define('BROADBAND_ISS', 'Catch Development');
define('COVERAGE_SYNC_TILES', true);
define('SS_DATABASE_CLASS', 'SQLitePDODatabase');
define('SS_DATABASE_USERNAME', 'root');
define('SS_DATABASE_PASSWORD', '');
define('SS_SQLITE_DATABASE_PATH', ':memory:');
define('SS_DATABASE_SERVER', 'localhost');
define('SS_DATABASE_CHOOSE_NAME', true);
define('SS_DEFAULT_ADMIN_USERNAME', 'admin');
define('SS_DEFAULT_ADMIN_PASSWORD', 'admin');
define('SS_SEND_ALL_EMAILS_TO', 'dev@catch.co.nz');
\$_FILE_TO_URL_MAPPING[dirname(__FILE__)] = 'http://localhost:8000';
" > _ss_environment.php
````

#### MySQL on PHP inbuilt server

##### create the db
````bash
./bin/create_db_dev
````

##### create the config
````bash
echo "<?php
define('APPLICATION_ENV', 'development');
define('SS_DATABASE_CLASS', 'MySQLDatabase');
define('SS_DATABASE_USERNAME', 'ss_template');
define('SS_DATABASE_PASSWORD', '12e646d36d9cb2cb2feafff2b8feaff2b812e646');
define('SS_DATABASE_NAME', 'ss_template');
define('SS_DATABASE_SERVER', 'localhost');
define('SS_DEFAULT_ADMIN_USERNAME', 'admin');
define('SS_DEFAULT_ADMIN_PASSWORD', 'admin');
define('SS_SEND_ALL_EMAILS_TO', 'danwest78@gmail.com');
\$_FILE_TO_URL_MAPPING[dirname(__FILE__)] = 'http://localhost:8000';
" > _ss_environment.php
````

#### MySQL on Apache

##### create the db
````bash
./bin/create_db_dev
````

##### create the vhost

`/path/to/vhostfile` defaults to `/etc/apache2/extra/httpd-vhosts.conf`

````bash
./bin/create_vhost_dev /path/to/vhostfile
````

NB you may need to enable the vhost and reload your apache configuration after this e.g.
````bash
sudo apachectl restart
````

##### create the config
````bash
echo "<?php
define('APPLICATION_ENV', 'development');
define('SS_DATABASE_CLASS', 'MySQLDatabase');
define('SS_DATABASE_USERNAME', 'ss_template');
define('SS_DATABASE_PASSWORD', '12e646d36d9cb2cb2feafff2b8feaff2b812e646');
define('SS_DATABASE_NAME', 'ss_template');
define('SS_DATABASE_SERVER', 'localhost');
define('SS_DEFAULT_ADMIN_USERNAME', 'admin');
define('SS_DEFAULT_ADMIN_PASSWORD', 'admin');
define('SS_SEND_ALL_EMAILS_TO', 'danwest78@gmail.com');
\$_FILE_TO_URL_MAPPING[dirname(__FILE__)] = 'http://ss_template.loc';
" > _ss_environment.php
````

### 3. Install Local Dependencies

````bash
bundle install --path vendor
composer install
bower install
npm install
````

### 4. Run dev build

````bash
public/framework/sake dev/build flush=1
````

### 5. Compile Assets

````
gulp
````

### 6. Done

You should be good to go now - you can run the PHP server with

````bash
php -S 0.0.0.0:8000
````

or just hit `http://ss_template.loc` if you are using apache

## Tasks

### Watch

````bash
gulp watch
````

### Build

````bash
gulp build
````

### Clean

````bash
gulp clean
````

## master library scripts

do a bower update and clone the master lib from git (so you can push chnages made there back to git)
````bash
./bin/bower-update
````

push the master library and the silverstripe project back to their respective git repos
````bash
./bin/push-all "commit message"
````

## other special scripts

PHP REPL with SS Framework
````bash
./bin/ss-console
````

## tests

you run the tests like so

you will need sqlite and the php bindings to run the tests

````bash
bin/test {TESTFRAMEWORK} {TEST}
````

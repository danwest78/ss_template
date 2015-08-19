<?php

// ------------------
// set some constants
// ------------------

if (!defined('PROJECT_PATH'))
    define('PROJECT_PATH', __DIR__);

if (!defined('PUBLIC_PATH'))
    define('PUBLIC_PATH', realpath(__DIR__ . '/..'));

if (!defined('APP_PATH'))
    define('APP_PATH', realpath(__DIR__ . '/../..'));

// ---------------------------
// Rationalise the environment
// ---------------------------

// The following env vars should be set in the _ss_environment.php file,
// if they are not then we need to hack around until we get a working configuration
// APPLICATION_ENV
// SS_DATABASE_CLASS
// SS_DATABASE_USERNAME
// SS_DATABASE_PASSWORD
// SS_DATABASE_NAME
// SS_DATABASE_SERVER
// BROADBAND_ISS
// COVERAGE_SYNC_TILES

// APPLICATION_ENV
if (!defined('APPLICATION_ENV') && defined('SS_ENVIRONMENT_TYPE')) {
    switch (SS_ENVIRONMENT_TYPE) {

        case 'live':
            define('APPLICATION_ENV', 'production');
            break;

        case 'test':
            define('APPLICATION_ENV', 'staging');
            break;

        case 'dev':
            define('APPLICATION_ENV', 'development');
            break;
    }
}

// SS_SEND_ALL_EMAILS_TO
if (!defined('SS_SEND_ALL_EMAILS_TO') && APPLICATION_ENV != 'production')
    define('SS_SEND_ALL_EMAILS_TO', 'danwest78@gmail.com');

// SS_DEFAULT_ADMIN_USERNAME && SS_DEFAULT_ADMIN_PASSWORD
if (APPLICATION_ENV == 'staging' || APPLICATION_ENV == 'development') {

    if (!defined('SS_DEFAULT_ADMIN_USERNAME'))
        define('SS_DEFAULT_ADMIN_USERNAME', 'admin');

    if (!defined('SS_DEFAULT_ADMIN_PASSWORD'))
        define('SS_DEFAULT_ADMIN_PASSWORD', 'admin');
}

// --------
// Composer
// --------

if (file_exists(APP_PATH . '/vendor/autoload.php'))
    require_once APP_PATH . '/vendor/autoload.php';

if (file_exists(PUBLIC_PATH . '/vendor/autoload.php'))
    require_once PUBLIC_PATH . '/vendor/autoload.php';

// ----------------------------------------
// Do initial setup before loading env conf
// ----------------------------------------

global $project;

// set the project and the theme
$project = 'project';
SSViewer::set_theme('project');

// Set the site locale
i18n::set_locale('en_NZ');
ini_set("date.timezone","Pacific/Auckland");


// --------------------------------------------
// Prevent the public site from loading jquery / admin panel css
// -------------------------------------------

RequirementsHelper::require_block(array(
    'framework/thirdparty/jquery/jquery.js',
    'admin-panel/js/build/admin-panel.js',
    'admin-panel/css/css.css',
    '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js',
    '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.js'
));

// let the cms load its preferred version of jquery
LeftAndMainHelper::require_unblock(array(
    'framework/thirdparty/jquery/jquery.js'
));

// -------------------------------------------
// HTML editor config
// -------------------------------------------

HtmlEditorConfig::get('cms')->setOption('extended_valid_elements', 'img[class|src|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|usemap|data*],iframe[src|name|width|height|align|frameborder|marginwidth|marginheight|scrolling],object[width|height|data|type],param[name|value],map[class|name|id],area[shape|coords|href|target|alt],ol[class|start]');

// -------------
// load env conf
// -------------

require_once('conf/ConfigureFromEnv.php');

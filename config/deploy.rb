require 'mina/bundler'
require 'mina/git'
require 'mina/whenever'
require 'yaml'

env = ENV['to']
full_setup = ENV['full'] || false

# validate env
unless ['production', 'staging'].include? env
  puts 'unsupported env'
  exit
end

# load config
conf = YAML.load File.open(File.dirname(__FILE__) + "/config.yml", "rb").read

# apply settings
set :env, env
set :rails_env, env
set :id, 'nzoc001'
set :full_setup, full_setup
set :vhost, id + '_' +  env
set :vhost_domain, conf[env]['domains']['server_name']
set :allow_from, conf[env]['allow_from']
set :vhost_aliases, conf[env]['domains']['server_aliases'] || []
set :domain, conf[env]['domains']['deploy']
set :broadband_iss, conf[env]['broadband_iss']
set :deploy_to, '/var/www/' + id + '_' + env
set :repository, 'git@gl.catch.co.nz:nzoc/rio-2016.git'
set :branch, 'master'
set :keep_releases, 2
set :term_mode, :system
set :user, 'root'
set :shared_paths, [
  'log',
  'vendor',
  'node_modules',
  'public/silverstripe-cache',
  'public/themes/project/thirdparty',
  '_ss_environment.php',
  'public/assets'
]

# bundler settings
set :bundle_bin, 'bundle'
set :bundle_path, './vendor/bundle'
set :bundle_options, lambda { %{--without development:test --path "#{bundle_path}" --binstubs bin/ --deployment} }


desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do

    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'

    # invoke :'bundle:install'
    # we are omitting the symlink step because vendor should already be symlinked
    queue %{
      echo "\n-----> Installing gem dependencies using Bundler"
      #{echo_cmd %[mkdir -p "#{File.dirname bundle_path}"]}
      #{echo_cmd %[#{bundle_bin} install #{bundle_options}]}
    }

    queue! %[composer install --no-dev]
    queue! %[npm install]
    queue! %[bower install --allow-root && bower update --allow-root]
    queue! %[gulp]


    to :launch do

      # handle cron
      invoke :'whenever:update'
      queue "echo \"\nPlease review the crontab below!!\n\""
      queue 'crontab -l'
      queue "echo \"\n\n\""

      # regenerate autoload files
      queue! %[cd #{deploy_to}/current && composer dump-autoload]

      # dev build
      queue! %[rm -rf #{deploy_to}/shared/public/silverstripe-cache/*]
      queue! %[chown www-data:www-data #{deploy_to}/current/public/framework/sake]
      queue! %[chmod +x #{deploy_to}/current/public/framework/sake]
      queue! %[bash #{deploy_to}/current/bin/www-dev-build]
      queue! %[bash #{deploy_to}/current/public/framework/sake dev/build flush=1]

      # add http basic auth
    #   conditional = "<If \"%{REMOTE_ADDR} == '118.148.3.205'\">\nAuthType Basic\nAuthName \"restricted area\"\nAuthUserFile #{deploy_to}/current/apache/.htpasswd\nrequire valid-user\n</If>"
    #   escaped = conditional.gsub(/"/, '\"')
    #   queue %[echo "#{escaped}" >> #{deploy_to}/current/public/.htaccess]

      # set permissions and restart
      queue! %[chown -R www-data:www-data "#{deploy_to}/shared"]
      queue! %[chmod -R 700 "#{deploy_to}/shared/log"]
      queue! %[a2ensite "#{vhost}" && service apache2 reload]

      # cleanup!
      invoke :'deploy:cleanup'

    end

  end
end

task :setup => :environment do

  # log
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  # db
  queue 'echo "You will need to input the password for your mysql server\'s root user"'
  queue! %[echo "CREATE DATABASE IF NOT EXISTS #{conf[env]['db']['name']};
GRANT ALL ON #{conf[env]['db']['name']}.* TO '#{conf[env]['db']['user']}'@'localhost' IDENTIFIED BY '#{conf[env]['db']['pass']}';
FLUSH PRIVILEGES;" | mysql --host 127.0.0.1 --port 3306 -u root -p]

  # vendored assets
  queue! %[mkdir -p "#{deploy_to}/shared/node_modules"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/node_modules"]
  queue! %[mkdir -p "#{deploy_to}/shared/vendor"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/vendor"]
  queue! %[mkdir -p "#{deploy_to}/shared/public/themes/project/thirdparty"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/themes/project/thirdparty"]

  # generated files
  queue! %[mkdir -p "#{deploy_to}/shared/public/assets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/assets"]
  queue! %[mkdir -p "#{deploy_to}/shared/public/silverstripe-cache"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/silverstripe-cache"]

  # modules.each do |m|
  #   queue! %[mkdir -p "#{deploy_to}/shared/#{m}"]
  #   queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{m}"]
  # end

  # config
  queue! %[echo "<?php
define('APPLICATION_ENV', '#{env}');
define('SS_DATABASE_CLASS', 'MySQLDatabase');
define('SS_DATABASE_USERNAME', '#{conf[env]['db']['user']}');
define('SS_DATABASE_PASSWORD', '#{conf[env]['db']['pass']}');
define('SS_DATABASE_NAME', '#{conf[env]['db']['name']}');
define('SS_DATABASE_SERVER', 'localhost');
define('SS_DEFAULT_ADMIN_USERNAME', 'admin');
define('SS_DEFAULT_ADMIN_PASSWORD', 'alice25');
define('SS_SEND_ALL_EMAILS_TO', '#{conf[env]['send_all_mail_to']}');
\\$_FILE_TO_URL_MAPPING['#{deploy_to + '/current/public'}'] = 'http://#{vhost_domain}';
" > #{deploy_to}/shared/_ss_environment.php]

  # permissions
  queue! %[chown -R www-data:www-data "#{deploy_to}/shared"]

  # Server Name
  cache_disable = 'CacheDisable http://' + vhost_domain + '/admin' + "\n"
  cache_disable += 'CacheDisable http://' + vhost_domain + '/dev' + "\n"
  cache_disable += 'CacheDisable https://' + vhost_domain + '/admin' + "\n"
  cache_disable += 'CacheDisable https://' + vhost_domain + '/dev' + "\n"

  # Server aliases
  alias_str = ""
  vhost_aliases.each do |vhost_alias|
    alias_str += "ServerAlias " + vhost_alias + "\n"
    cache_disable += 'CacheDisable http://' + vhost_alias + '/admin' + "\n"
    cache_disable += 'CacheDisable http://' + vhost_alias + '/dev' + "\n"
    cache_disable += 'CacheDisable https://' + vhost_alias + '/admin' + "\n"
    cache_disable += 'CacheDisable https://' + vhost_alias + '/dev' + "\n"
  end

  # allow from
  allow = 'Require all granted';
  allow = 'Require ip ' + allow_from if allow_from

  # CacheDisable


  # vhost
  vh_cnf = %[
<VirtualHost *:80>

  ServerAdmin dev@catch.co.nz
  DocumentRoot "#{deploy_to}/current/public"
  ServerName #{vhost_domain}
  #{alias_str}

  #RewriteEngine On
  #RewriteRule ^/(.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]

  ExpiresActive On
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/pdf "access plus 1 month"
  ExpiresByType text/x-javascript "access plus 1 month"
  ExpiresByType application/x-shockwave-flash "access plus 1 month"
  ExpiresByType image/x-icon "access plus 1 year"
  ExpiresByType text/html "access plus 1 day"
  ExpiresDefault "access plus 2 days"
  CacheEnable disk /
  CacheDirLevels 5
  CacheDirLength 3
  CacheLock On
  CacheLockMaxAge 5
  CacheLockPath /var/cache/locks
  #{cache_disable}

  ErrorLog "/var/log/apache2/#{id}_error_log"
  CustomLog "/var/log/apache2/#{id}_access_log" common

  <Directory "#{deploy_to}/current/public">
    #{allow}
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
  </Directory>

  <Directory "#{deploy_to}/current/public/assets/replicant">
    Require all denied
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
  </Directory>

</VirtualHost>

<VirtualHost *:443>

  SSLEngine on
  SSLCertificateFile "#{deploy_to}/current/ssl/ssl.crt"
  SSLCertificateKeyFile "#{deploy_to}/current/ssl/ssl.key"

  ServerAdmin dev@catch.co.nz
  DocumentRoot "#{deploy_to}/current/public"
  ServerName #{vhost_domain}
  #{alias_str}

  ExpiresActive On
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/pdf "access plus 1 month"
  ExpiresByType text/x-javascript "access plus 1 month"
  ExpiresByType application/x-shockwave-flash "access plus 1 month"
  ExpiresByType image/x-icon "access plus 1 year"
  ExpiresByType text/html "access plus 1 day"
  ExpiresDefault "access plus 2 days"
  CacheEnable disk /
  CacheDirLevels 5
  CacheDirLength 3
  CacheLock On
  CacheLockMaxAge 5
  CacheLockPath /var/cache/locks
  #{cache_disable}

  ErrorLog "/var/log/apache2/#{id}_error_log"
  CustomLog "/var/log/apache2/#{id}_access_log" common

  <Directory "#{deploy_to}/current/public">
    #{allow}
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
  </Directory>

  <Directory "#{deploy_to}/current/public/assets/replicant">
    Require all denied
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
  </Directory>

</VirtualHost>
  ]

  queue 'echo "' + vh_cnf.gsub('"','\"') + '" > /etc/apache2/sites-available/' + vhost + '.conf'
  # queue! %[a2ensite "#{vhost}" && service apache2 reload]

end

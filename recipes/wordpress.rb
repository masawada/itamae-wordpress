require 'open-uri'

# include recipes
include_recipe "./nginx.rb"
include_recipe "./mysql.rb"
include_recipe "./php5-fpm.rb"

# server name
SERVER_NAME = node['server_name']

# use unzip
package "unzip"

# create www dir
directory "/var/www"

execute "download and extract wordpress" do
  commands = [
    "cd /var/www/",
    "wget \"https://ja.wordpress.org/latest-ja.zip\"",
    "unzip latest-ja.zip",
    "mv wordpress #{SERVER_NAME}",
    "rm -rf latest-ja.zip",
    "chown -R www-data:www-data #{SERVER_NAME}"
  ]

  command commands.join(" && ")
  not_if "test -d /var/www/#{SERVER_NAME}"
  user "root"
end

# nginx conf
conf_files = [
  "server.conf",
  "global/restrictions.conf",
  "global/wordpress.conf"
]

directory "/etc/nginx/sites-available/global"

conf_files.each do |conf|
  template "/etc/nginx/sites-available/#{conf}" do
    source "../templates/nginx/#{conf}.erb"
    variables({
      server_name: SERVER_NAME
    })
    mode "644"
    owner "root"
    group "root"

    notifies :restart, "service[nginx]"
  end
end

execute "create symlink" do
  command "sudo ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/#{SERVER_NAME}.conf"
  not_if "test -e /etc/nginx/sites-enabled/#{SERVER_NAME}.conf"
end

# setup database
MYSQL_ROOT_PASSWORD = node['mysql']['root']
WP_DB_NAME = node['wordpress']['db_name']
WP_DB_USER = node['wordpress']['db_user']
WP_DB_PASSWORD = node['wordpress']['db_password']

execute "mysql -uroot -p#{MYSQL_ROOT_PASSWORD} -e \"CREATE DATABASE IF NOT EXISTS #{WP_DB_NAME} character set utf8\""
execute "mysql -uroot -p#{MYSQL_ROOT_PASSWORD} -e \"GRANT ALL ON \\`#{WP_DB_NAME}\\`.* to '#{WP_DB_USER}'@'localhost' identified by '#{WP_DB_PASSWORD}'\""


# create wp-config.php
## obtain keys
keys = []
open ("https://api.wordpress.org/secret-key/1.1/salt/") {|io|
  keys << io.read
}

## generate wp-config from template
template "/var/www/#{SERVER_NAME}/wp-config.php" do
  source "../templates/wordpress/wp-config.php.erb"
  variables ({
    db_name: WP_DB_NAME,
    db_user: WP_DB_USER,
    db_password: WP_DB_PASSWORD,
    secret_keys: keys.join("\n")
  })
  mode "644"
  owner "root"
  group "root"

  not_if "test -e /var/www/#{SERVER_NAME}/wp-config.php"
end

# wordpress uses ssh2 module to update
directory "/var/www/.ssh"
execute "generate ssh keys" do
  commands = [
    "cd /var/www/.ssh",
    "ssh-keygen -t rsa -N \"\" -f id_rsa",
    "cp id_rsa.pub authorized_keys",
    "chown www-data:www-data id_rsa id_rsa.pub authorized_keys",
    "mv id_rsa id_rsa.pub /usr/local"
  ]

  command commands.join(" && ")
  not_if "test -e /usr/local/id_rsa"
  user "root"
end

service "php5-fpm" do
  action :restart
end

service "nginx" do
  action :restart
end

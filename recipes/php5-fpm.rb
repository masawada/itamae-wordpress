# php5-fpm.rb
service "php5-fpm"

# install packages
package "php5-dev"
package "php5-fpm"
package "php5-mysqlnd"
package "php-apc"
package "php-pear"
package "libssh2-1"
package "libssh2-1-dev"
package "build-essential"

# change php-fpm listen owner and group
remote_file "/etc/php5/fpm/pool.d/www.conf" do
  source "../files/php/www.conf"
  mode "644"
  owner "root"
  group "root"

  notifies :reload, "service[php5-fpm]"
end

# install ssh2 module
execute "install pecl ssh" do
  command "yes "" | sudo pecl install channel://pecl.php.net/ssh2-0.12"
  not_if "pecl list | grep ssh2"
end

remote_file "/etc/php5/mods-available/ssh2.ini" do
  source "../files/php/ssh2.ini"
  mode "644"
  owner "root"
  group "root"

  notifies :reload, "service[php5-fpm]"
end

execute "create symlink" do
  command "sudo ln -s /etc/php5/mods-available/ssh2.ini /etc/php5/fpm/conf.d/ssh2.ini"
  not_if "test -e /etc/php5/fpm/conf.d/ssh2.ini"
end

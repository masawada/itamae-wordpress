# conf
MYSQL_ROOT_PASSWORD = node['mysql']['root']
MYSQL_USER = node['mysql']['user']
MYSQL_PASSWORD = node['mysql']['password']

# install mysql
packages = [
  "libmysqlclient-dev",
  "mysql-common",
  "mysql-client",
  "mysql-server"
]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# create database
execute "set root password" do
  command "echo \"root password modified.\""
  only_if "mysql -uroot -e \"SET PASSWORD=PASSWORD('#{MYSQL_ROOT_PASSWORD}')\""
end

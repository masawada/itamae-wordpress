# nginx.rb
service "nginx"

execute "download nginx_signing.key" do
  command "wget \"http://nginx.org/keys/nginx_signing.key\""
  not_if "sudo apt-key list | grep nginx"
end

execute "add key" do
  command "sudo apt-key add nginx_signing.key"
  only_if "test -e nginx_signing.key"
end

execute "delete nginx_signing.key" do
  command "rm -rf nginx_signing.key"
  only_if "test -e nginx_signing.key"
end

execute "add repos" do
  repos = [
    "deb http://nginx.org/packages/debian/ wheezy nginx",
    "deb-src http://nginx.org/packages/debian/ wheezy nginx"
  ]

  command repos.map{|repo| "echo \"#{repo}\" >> /etc/apt/sources.list"}.join("&&")
  not_if "grep \"nginx\" /etc/apt/sources.list"
end

execute "sudo aptitude update"

package "nginx" do
  action :install
end

directory "/etc/nginx/sites-available"
directory "/etc/nginx/sites-enabled"

remote_file "/etc/nginx/nginx.conf" do
  source "../files/nginx/nginx.conf"
  mode "644"
  owner "root"
  group "root"
end

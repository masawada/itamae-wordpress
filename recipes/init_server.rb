# install packages
package "chkrootkit"
package "ufw"
package "vim"
package "mosh"

# configure ufw
execute "sudo ufw default deny"
execute "sudo ufw allow ssh"
execute "sudo ufw allow http"
execute "sudo ufw allow mosh"
execute "yes | sudo ufw enable"

execute "backup ufw config" do
  command "cp /etc/default/ufw /etc/default/ufw.orig"
  not_if "test -e /etc/default/ufw.orig"
end

execute "update ufw config" do
  command "sed -i -e 's/IPV6=yes/IPV6=no/' /etc/default/ufw"
  user "root"
end

execute "sudo ufw reload"

# configure ssh
execute "backup sshd_config" do
  command "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig"
  not_if "test -e /etc/ssh/sshd_config.orig"
end

execute "do not permit root login" do
  command "sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
  user "root"
end

execute "do not permit password authentication" do
  command "sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
  user "root"
end

service "ssh" do
  action :restart
end

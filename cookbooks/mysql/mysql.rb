require_relative "../setup_secret"

# mysql8インストール
package node["mysql"]["url"] do
  not_if "sudo yum repolist enabled | grep 'mysql#{node[:mysql][:version]}-community.*'"
end

package "mysql-community-server" do
  not_if "mysql --version"
end

# mysql自動起動の設定
service "mysqld" do
  action [:enable, :start]
end

#firewalldの設定
execute "firewalld mysql" do
  command "sudo firewall-cmd --add-service=mysql --zone=public --permanent"
end

execute "firewalld reload" do
  command "firewall-cmd --reload"
end

# 初期パスワードの変更
execute "change mysql password test" do
  command <<-EOH
PASS=`sudo cat /var/log/mysqld.log | grep password | cut -d ' ' -f 13 | tr -d '\n'`
mysqladmin password #{secret["mysql_password"]} -u root -p$PASS
EOH
  not_if  "mysql -u root -p#{secret["mysql_password"]} -e 'SHOW databases;'"
end

# 外部から接続できるユーザを作成
execute "create mysql user" do
  command "mysql -u root -p#{secret["mysql_password"]} -e 'CREATE USER #{node[:app][:user]}@#{node[:app][:ip_address]} IDENTIFIED BY \"#{secret["mysql_password"]}\";'"
  not_if  "mysql -u root -p#{secret["mysql_password"]} -e 'SELECT user FROM mysql.user WHERE user = \"#{node[:app][:user]}\";' | grep #{node[:app][:user]}"
end

execute "grant all" do
  command "mysql -u root -p#{secret["mysql_password"]} -e 'GRANT ALL ON *.* TO #{node[:app][:user]}@#{node[:app][:ip_address]};'"
  not_if  "mysql -u root -p#{secret["mysql_password"]} -e 'SHOW GRANTS FOR #{node[:app][:user]}@#{node[:app][:ip_address]};' | grep CREATE"
end

execute "flush privileges #{secret["mysql_password"]}" do
  command "mysql -u root -p#{secret["mysql_password"]} -e 'FLUSH PRIVILEGES;'"
end



#


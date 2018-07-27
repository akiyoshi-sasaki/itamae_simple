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

# デフォルトパスワードの取得
result = run_command("cat /var/log/mysqld.log | grep password | cut -d ' ' -f 13 | tr -d '\n'")
change_mysql_password_command = "mysqladmin password #{node[:mysql][:password]} -u root -p'" + result.stdout + "'"

# 初期パスワードの変更
execute "change mysql password" do
  command change_mysql_password_command
  not_if  "mysql -u root -p#{node[:mysql][:password]} -e 'SHOW databases;'"
end

# 外部から接続できるユーザを作成
execute "create mysql user" do
  command "mysql -u root -p#{node[:mysql][:password]} -e 'CREATE USER #{node[:app][:user]}@#{node[:app][:ip_address]} IDENTIFIED BY \"#{node[:mysql][:password]}\";'"
  not_if  "mysql -u root -p#{node[:mysql][:password]} -e 'SELECT user FROM mysql.user WHERE user = \"#{node[:app][:user]}\";' | grep #{node[:app][:user]}"
end

execute "grant all" do
  command "mysql -u root -p#{node[:mysql][:password]} -e 'GRANT ALL ON *.* TO #{node[:app][:user]}@#{node[:app][:ip_address]};'"
  not_if  "mysql -u root -p#{node[:mysql][:password]} -e 'SHOW GRANTS FOR #{node[:app][:user]}@#{node[:app][:ip_address]};' | grep CREATE"
end

execute "flush privileges #{node[:mysql][:password]}" do
  command "mysql -u root -p#{node[:mysql][:password]} -e 'FLUSH PRIVILEGES;'"
end



#


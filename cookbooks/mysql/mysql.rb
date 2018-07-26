# mysql8インストール
package node['mysql']['url'] do
  not_if 'sudo yum repolist enabled | grep "mysql8.*-community.*"'
end

package 'mysql-community-server' do
  not_if 'mysql --version'
end

# mysql自動起動の設定
service 'mysqld' do
  action [:enable, :start]
end

#firewalldの設定
execute 'firewalld mysql' do
  command 'sudo firewall-cmd --add-service=mysql --zone=public --permanent'
end

execute 'firewalld reload' do
  command 'firewall-cmd --reload'
end

# デフォルトパスワードの取得
result = run_command("cat /var/log/mysqld.log | grep password | cut -d ' ' -f 13 | tr -d '\n'")
change_mysql_password_command = 'mysqladmin password Password_0 -u root -p"' + result.stdout + '"'

# 初期パスワードの変更
execute 'change mysql password' do
  command change_mysql_password_command
  not_if  'mysql -u root -pPassword_0 -e "SHOW databases;"'
end

APP_USER = node['app']['user']
APP_IP_ADDRESS = node['app']['ip-address']

# 外部から接続できるユーザを作成
execute 'create mysql user' do
  command 'mysql -u root -pPassword_0 -e "CREATE USER vagrant@10.10.10.10 IDENTIFIED BY \'Password_0\';"'
  not_if  'mysql -u root -pPassword_0 -e "SELECT user FROM mysql.user WHERE user = \'vagrant\';" | grep vagrant'
end

execute 'grant all' do
  command 'mysql -u root -pPassword_0 -e "GRANT ALL ON *.* TO vagrant@10.10.10.10;"'
  not_if  'mysql -u root -pPassword_0 -e "SHOW GRANTS FOR vagrant@10.10.10.10;" | grep CREATE'
end

execute 'flush privileges' do
  command 'mysql -u root -pPassword_0 -e "FLUSH PRIVILEGES;"'
end



#


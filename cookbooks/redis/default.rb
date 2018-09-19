
# gccインストール
package "gcc" do
  not_if "gcc --version"
end

# makeインストール
package "make" do
  not_if "make --version"
end

# tclインストール
package "tcl" do
  not_if "tcl --version"
end

# redis用ディレクトリの用意
execute "make dir" do
  command <<-EOH
mkdir /etc/redis /var/log/redis
chmod 755 /etc/redis
chmod 755 /var/log/redis
EOH

  not_if "test -d /etc/redis -a /var/log/redis"
end

# redisインストールのためにremiリポジトリの用意
package "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm" do
  not_if "rpm -qa | grep remi"
end

# redisインストールのためにepelリポジトリの用意
package "epel-release"do
  not_if "rpm -qa | grep epel"
end

package "redis" do
  not_if "redis --version"
  options "--enablerepo=remi,epel"
end

# redis設定ファイルの用意
execute "redis conf" do
  command "cp -p /etc/redis.conf /etc/redis/6379.conf"
  not_if "test -f /etc/redis/6379.conf"
end

# redis設定ファイルの変更
file "/etc/redis/6379.conf" do
  action :edit
  block do |content|
    content.gsub!(/^#?supervised.+$/, %q(supervised systemd))
    content.gsub!(/^#?daemonize.+$/, %q(daemonize no))
    content.gsub!(/^#?pidfile.+$/, %q(pidfile /var/run/redis_6379.pid))
    content.gsub!(/^#?port.+$/, %q(port 6379))
    content.gsub!(/^#?bind.+$/, %q(bind 127.0.0.1))
    content.gsub!(/^#?loglevel.+$/, %q(loglevel notice))
    content.gsub!(/^#?logfile.+$/, %q(dbfilename 6379.rdb))
    content.gsub!(/^#?dir \.\/.+$/, %q(dir /var/run/redis))
    content.gsub!(/^#?maxclients.+$/, %q(maxclients 1024))
  end
end

# サービス用のredis設定ファイルを作成
template "server.conf" do
  path   "/etc/systemd/system/redis.service"
  source "../redis/templates/redis.service"
  mode   "600"
end

# サービス用のredis設定ファイルを作成
template "server.conf" do
  path   "/etc/systemd/system/redis.service"
  source "../redis/templates/redis.service"
  mode   "600"
end

# libのパーミッションを変更
execute "chmod lib redis" do
  command "chmod 755 /var/lib/redis"
end

#firewalldの設定
execute "firewalld redis" do
  command "firewall-cmd --add-port=6379/tcp --permanent"
end

execute "firewalld reload" do
  command "firewall-cmd --reload"
end

# systemdのリロード
execute "reload systemctl" do 
  command "systemctl daemon-reload"
end 

# 自動起動サービスとして登録
execute "chkconfig redis" do 
  command "chkconfig redis on"
end 

# redis自動起動の設定
service "redis" do
  action [:enable, :start]
end



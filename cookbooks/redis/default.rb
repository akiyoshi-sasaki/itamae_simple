
# gcc���󥹥ȡ���
package "gcc" do
  not_if "gcc --version"
end

# make���󥹥ȡ���
package "make" do
  not_if "make --version"
end

# tcl���󥹥ȡ���
package "tcl" do
  not_if "tcl --version"
end

# redis�ѥǥ��쥯�ȥ���Ѱ�
execute "make dir" do
  command <<-EOH
mkdir /etc/redis /var/log/redis
chmod 755 /etc/redis
chmod 755 /var/log/redis
EOH

  not_if "test -d /etc/redis -a /var/log/redis"
end

# redis���󥹥ȡ���Τ����remi��ݥ��ȥ���Ѱ�
package "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm" do
  not_if "rpm -qa | grep remi"
end

# redis���󥹥ȡ���Τ����epel��ݥ��ȥ���Ѱ�
package "epel-release"do
  not_if "rpm -qa | grep epel"
end

package "redis" do
  not_if "redis --version"
  options "--enablerepo=remi,epel"
end

# redis����ե�������Ѱ�
execute "redis conf" do
  command "cp -p /etc/redis.conf /etc/redis/6379.conf"
  not_if "test -f /etc/redis/6379.conf"
end

# redis����ե�������ѹ�
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

# �����ӥ��Ѥ�redis����ե���������
template "server.conf" do
  path   "/etc/systemd/system/redis.service"
  source "../redis/templates/redis.service"
  mode   "600"
end

# �����ӥ��Ѥ�redis����ե���������
template "server.conf" do
  path   "/etc/systemd/system/redis.service"
  source "../redis/templates/redis.service"
  mode   "600"
end

# lib�Υѡ��ߥå������ѹ�
execute "chmod lib redis" do
  command "chmod 755 /var/lib/redis"
end

#firewalld������
execute "firewalld redis" do
  command "firewall-cmd --add-port=6379/tcp --permanent"
end

execute "firewalld reload" do
  command "firewall-cmd --reload"
end

# systemd�Υ����
execute "reload systemctl" do 
  command "systemctl daemon-reload"
end 

# ��ư��ư�����ӥ��Ȥ�����Ͽ
execute "chkconfig redis" do 
  command "chkconfig redis on"
end 

# redis��ư��ư������
service "redis" do
  action [:enable, :start]
end



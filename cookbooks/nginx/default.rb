# リポジトリ追加用のファイルを作成
template "nginx.repo" do
  path   "/etc/yum.repos.d/nginx.repo"
  source "../nginx/templates/nginx.repo"
  mode   "600"
end

package "nginx" do
  not_if "nginx --version"
  # version "1.15"
end

# サービス用のnginx設定ファイルを作成
template "server.conf" do
  path   "/etc/nginx/conf.d/server.conf"
  source "../nginx/templates/server.conf"
  mode   "600"
end

# 初期設定ファイルを呼ばないようにする
execute "rename sshd_config" do
  command "mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.org"
  only_if "test -e /etc/nginx/conf.d/default.conf"
end

# nginxのssl設定用ディレクトリ作成
execute "mkdir ssl" do
  command "mkdir /etc/nginx/ssl"
  not_if  "test -d /etc/nginx/ssl"
end

# オレオレ証明書の作成
execute "make SSL server certificate" do
  command <<-EOH
cd /etc/nginx/ssl
openssl genrsa 2048 > server.key
openssl req -new -key server.key -subj '/C=/ST=/L=/O=/OU=/CN="#{node[:nginx][:fqdn]}"' > server.csr
openssl x509 -req -days 3650 -signkey server.key < server.csr > server.crt
EOH
  not_if "cd /etc/nginx/ssl && openssl req -text < server.csr"
end

# nginx自動起動の設定
service "nginx" do
  action [:enable, :start]
end
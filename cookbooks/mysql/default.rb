# mysql8インストール
package node["mysql"]["url"] do
  not_if "sudo yum repolist enabled | grep 'mysql#{node[:mysql][:version]}-community.*'"
end

package "mysql-community-server" do
  not_if "mysql --version"
end
# /etc/ssh/sshd_configのバックアップ
execute 'backup sshd_config' do
  command 'sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.org'
end

# rootログインの禁止
file "/etc/ssh/sshd_config" do
  action :edit
  block do |content|
    content.gsub!(/^#?PermitRootLogin.+$/, %q(PermitRootLogin without-password))
    content.gsub!(/^#?PasswordAuthentication.+$/, %q(PasswordAuthentication yes))
  end
end

execute 'restart sshd' do
  command 'sudo service sshd restart'
end

# vimのインストール
package 'vim-enhanced'

# wgetのインストール
package 'wget'

# firewalldの起動
service 'firewalld' do
  action [:enable, :start]
end

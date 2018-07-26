# /etc/ssh/sshd_configのバックアップ
execute 'backup sshd_config' do
  command 'sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.org'
end

# rootログインの禁止
template 'sshd_config' do
  path   '/etc/ssh/sshd_config'
  source '../templates/sshd_config'
  mode   '600'
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

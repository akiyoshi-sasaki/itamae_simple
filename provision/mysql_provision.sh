#!/bin/bash

cd /tmp

yum install -y rubygems git openssl-devel readline-devel zlib-devel

# install rbenv
if [ ! -d ~/.rbenv ];then
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source ~/.bashrc
fi

# install ruby-build plugin
if [ ! -d ~/.rbenv/plugins ];then
  mkdir ~/.rbenv/plugins
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  source ~/.bashrc
fi

# change ruby version
if ! rbenv versions | grep 2.2.5;then
  rbenv install 2.2.5
fi

rbenv global 2.2.5
rbenv rehash

touch Gemfile
cat << EOS > Gemfile
source "https://rubygems.org"

gem "rake"
gem "serverspec"
gem "itamae"
gem "reversible_cryptography"
gem "itamae-plugin-resource-encrypted_remote_file"
gem "dotenv"
EOS

gem install bundler
bundle install --path=vendor/bundle
bundle exec itamae local -j nodes/server.json roles/mysql.rb

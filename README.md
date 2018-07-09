# サーバ構築の基礎

## 概要

本課題ではServerspecで予め決められたテストが通るようにサーバの構築を行います．
今回はvagrant(virtualbox)で起動させた仮想マシンに対してServerspecのテストを実行し，
すべてのテストがオールグリーンになるようにサーバ構築を行います．
サーバは3台(app, mysql, redis)存在し，それぞれに別々のテストが用意されています．

## 構築

下記のコマンドでvmを3台構築します．ディストリビューションはすべてCentOS7となります．

```
$ vagrant up app
$ vagrant up mysql
$ vagrant up redis
```

### app

1. 共通設定
	- rootユーザでのパスワード認証によるログインを拒否
	- vimとwgetがインストール済み
	- firewalldが起動している
1. mysql
	- mysql8.0のクライアントがinstall済み
	- mysqlのVMで動いているmysql-serverにport番号3306で接続できる
1. webサーバ
	- nginxのversion1.15が起動している
	- nginx.serviceがsystemdで起動している
	- nginx.serviceがホストの起動時に立ち上がる
	- すべてのhttpへのアクセスが301を返してhttpsにリダイレクトする
	- nginxのstub_statusが`localhost/nginx_status`で見れる
	- `localhost/heartbeat`へのリクエストに空gifのレスポンスを返す
		- `access_log`への書き込みはしないようにする

### mysql

1. 共通設定
	- rootユーザでのパスワード認証によるログインを拒否
	- vimとwgetがインストール済み
	- firewalldが起動している
1. mysql
	- mysqlのversion8系が起動している
	- mysqld.serviceがsystemdで起動している
	- mysqld.serviceがホストの起動時に立ち上がる

### redis

1. 共通設定
	- rootユーザでのパスワード認証によるログインを拒否
	- vimとwgetがインストール済み
	- firewalldが起動している
1. redis
	- redisのversion4系が起動している
	- redis.serviceがsystemdで起動している
	- redis.serviceがホストの起動時に立ち上がる

## テストの実行

初回のみ下記コマンドを実行してください．
gemのパッケージマネージャであつbundlerのinstallと，必要なGemをbundlerでinstallしています．

```
$ gem install bundler
$ bundle install --path=vendor/bundle
```

その後下記のコマンドでテストを実行します．
vagrantユーザのログインパスワードは`vagrant`で管理者権限実行時のパスワードも`vagrant`となります．

```
$ bundle exec rake spec:app
$ bundle exec rake spec:mysql
$ bundle exec rake spec:redis
```

## ssh出来ない時

serverspecを実行した際に下記のような内容エラーが出る場合があります．

```
Authentication failed for user vagrant@10.10.10.200 (Net::SSH::AuthenticationFailed)
```

その場合はsshに接続に何かの問題があるので，`vagrant ssh` でloginしてsshができるよう設定を変更してください．

require 'spec_helper'

describe service("mysqld") do
	it { should be_enabled }
	it { should be_running }
end

describe port(3306) do
	it { should be_listening }
end

describe command("mysql --version") do
	its(:stdout) { should match /8\.0\.\d+/ }
end

describe file('/etc/my.cnf') do
	it { should be_file }
end

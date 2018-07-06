require 'spec_helper'

describe service("redis") do
	it { should be_enabled }
	it { should be_running }
end

describe port(6379) do
	it { should be_listening }
end

describe command('redis-cli -v') do
	its(:stdout) { should match /4\.\d+\.\d+/ }
end

describe command('redis-server -v') do
	its(:stdout) { should match /4\.\d+\.\d+/ }
end

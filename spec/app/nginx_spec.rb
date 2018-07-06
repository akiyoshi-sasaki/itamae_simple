require "spec_helper"

describe package("nginx") do
	it { should be_installed }
end

describe command("rpm -q nginx") do
	its(:stdout) { should match /1\.15/ }
end

describe service("nginx") do
	it { should be_enabled }
	it { should be_running }
end

describe port(80) do
	it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

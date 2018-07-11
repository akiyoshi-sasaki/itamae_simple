require "spec_helper"

describe command('curl -IL 10.10.10.200:3306') do
	its(:stdout) { should match /8\.\d+\.\d+/ }
end

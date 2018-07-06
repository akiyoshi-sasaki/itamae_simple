require "spec_helper"

describe command('mysql --version') do
	its(:stdout) { should match /8\.\d+\.\d+/}
end

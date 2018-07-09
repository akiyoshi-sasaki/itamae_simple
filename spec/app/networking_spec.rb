require "spec_helper"

describe command('curl -L 10.10.10.200:3306') do
	its(:exit_status) { should eq 0 }
end

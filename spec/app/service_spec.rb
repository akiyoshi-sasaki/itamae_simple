require "spec_helper"

describe command('curl -kL http://localhost -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^200$/ }
end

describe command('curl -Lk localhost/nginx_status -o /dev/null -w "%{http_code}\n" -s') do
	its(:stdout) { should match /^200$/ }
end

describe command('curl http://localhost -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^301$/ }
end

describe command('curl -kL http://localhost -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^200$/ }
end

describe command('curl -kL http://localhost/heartbeat') do
  its(:stdout) { should match /^GIF/ }
end

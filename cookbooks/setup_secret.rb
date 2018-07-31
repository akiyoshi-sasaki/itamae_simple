
require 'dotenv'
Dotenv.load

encrypted_remote_file "./nodes/secrets.json" do
  owner    "root"
  group    "root"
  source   "../nodes/secrets.json.encrypted"
  password ENV["PASSWORD"]
end
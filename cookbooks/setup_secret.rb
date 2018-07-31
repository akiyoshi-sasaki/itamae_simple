require "reversible_cryptography"
require 'dotenv'
Dotenv.load

def secret
  secret_file = "./nodes/secrets.json.encrypted"
  if @secret.nil?
    password = ENV["PASSWORD"]
    encrypted_data = File.read(secret_file).strip
    decrypted_data = ReversibleCryptography::Message.decrypt(encrypted_data, password)
    @secret = JSON.load(decrypted_data)
  end
  @secret
end
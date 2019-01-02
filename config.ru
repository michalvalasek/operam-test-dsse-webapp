require 'dotenv/load'
required_keys = ['TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN']
missing_keys = required_keys.flatten - ::ENV.keys
if missing_keys.any?
  raise "Missing ENV variables: #{missing_keys.join(', ')}"
end

require './app'

run Sinatra::Application

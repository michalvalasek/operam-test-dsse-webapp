require 'net/http'
require 'json'

class RunGcloudFunction

  def initialize(fn_name, response_number, response_text)
    @fn_name = fn_name
    @response_number = response_number
    @response_text = response_text
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    case @fn_name
    when 'email'
      run_function('send-email')
    when 'tweet'
      run_function('post-tweet')
    end
  end

  private

  def run_function(fn_name)
    uri = URI.parse('https://us-central1-operam.cloudfunctions.net/' + fn_name)

    payload = JSON.generate({ sms_response: { number: @response_number, text: @response_text }})

    puts "Calling Cloud Function: #{fn_name}, #{payload}"

    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    # request.add_field "Metadata-Flavor", "Google"
    request.body = payload
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request request
  end
end

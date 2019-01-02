require 'aws-sdk-lambda'
require 'json'

class RunAwsLambda

  def initialize(fn_name, response_number, response_text)
    @fn_name = fn_name
    @response_number = response_number
    @response_text = response_text
    @client = Aws::Lambda::Client.new(region: 'us-east-1')
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    case @fn_name
    when 'email'
      run_lambda('OperamSendEmail')
    when 'tweet'
      run_lambda('OperamPostTweet')
    end
  end

  private

  def run_lambda(name)
    payload = JSON.generate({ sms_response: { number: @response_number, text: @response_text }})
    puts "Calling AWS lambda: #{name}, #{payload}"
    @client.invoke({
      function_name: name,
      invocation_type: 'RequestResponse',
      log_type: 'None',
      payload: payload
    })
  end
end

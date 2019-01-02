require 'sinatra'
require "sinatra/activerecord"
require 'twilio-ruby'

$settings = settings
if $settings.development?
  require 'pry'
end

enable :sessions
set :database, "sqlite3:operam.sqlite3"

require './models'
require './run_gcloud_function'

before do
  if session[:flash].present?
    @flash = session[:flash]
    session[:flash] = nil
  end
end

get '/' do
  # show form to enter new Task
  @task = Task.new
  erb :index
end

post '/tasks' do
  @task = Task.new(phone_number: params['phone_number'], cloud_function: params['cloud_function'])
  if @task.save
    @task.send_sms!
    session[:flash] = 'Task created and SMS sent to the target number.'
    redirect '/'
  else
    erb :index
  end
end

get '/tasks' do
  # list the pending Tasks
  @tasks = Task.pending.order(created_at: :desc)
  erb :tasks
end

get '/archive' do
  # list the archived Tasks
  # (archived = response has been received and followup triggered)
  @tasks = Task.processed.latest
  erb :archive
end

# Webhook for Twilio
get '/sms-received' do
  if params['AccountSid'] != ENV['TWILIO_ACCOUNT_SID']
    halt 401
  end

  response_number = params['From']
  response_text = params['Body']

  puts "Received SMS response from #{response_number}: #{response_text}"

  # find the relevant Task by phone number
  # and trigger the chosen followup action
  if @task = Task.pending.find_by(phone_number: response_number)
    RunGcloudFunction.call(@task.cloud_function, @task.phone_number, response_text)

    @task.update(response_processed: true, response_text: response_text)
  end
end

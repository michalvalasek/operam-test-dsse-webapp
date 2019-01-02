require 'sinatra'

class Task < ActiveRecord::Base

  validates :phone_number, presence: true, format: { with: /\A\+?[1-9]\d{1,14}\z/ }
  validates :cloud_function, presence: true, inclusion: { in: %w[email tweet] }

  scope :pending, ->{ where(response_processed: false) }
  scope :processed, ->{ where(response_processed: true) }
  scope :latest, ->(n=10){ order(updated_at: :desc).limit(n) }

  def send_sms!
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    target_number = $settings.development? ? ENV['TWILIO_DEV_NUMBER'] : self.phone_number
    client.messages.create({
      from: ENV['TWILIO_SOURCE_NUMBER'],
      to: target_number,
      body: 'What\'s on your mind right now?'
    })
  end
end

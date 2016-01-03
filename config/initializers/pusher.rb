require 'pusher'

if Rails.env == "production"
  Pusher.url = ENV["PUSHER_URL"]
  Pusher.logger = Rails.logger
else
  Pusher.app_id = Rails.application.secrets.pusher_app_id
  Pusher.key = Rails.application.secrets.pusher_key
  Pusher.secret = Rails.application.secrets.pusher_secret
end

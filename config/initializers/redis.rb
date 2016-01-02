uri = URI.parse(Rails.application.secrets.redis_url)
REDIS = Redis.new(:url => uri)

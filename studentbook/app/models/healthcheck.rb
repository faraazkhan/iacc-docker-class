class Healthcheck
  def self.healthy?
    redis = Redis.new(url: ENV['REDIS_URL'])
    redis.ping && ActiveRecord::Base.connected?  rescue false
  end
end

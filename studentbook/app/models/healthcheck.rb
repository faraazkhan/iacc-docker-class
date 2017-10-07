class Healthcheck
  def self.healthy?
    redis_url = "redis://:#{ENV.fetch("REDIS_PASSWORD")}@#{ENV.fetch("REDIS_HOST")}:6379/0"
    redis = Redis.new(url: redis_url)
    redis.ping && ActiveRecord::Base.connected?  rescue false
  end
end




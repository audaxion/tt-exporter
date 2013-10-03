require 'sidekiq/web'

if Rails.env == 'production'
  REDIS_CONFIG = { :url => "unix:///#{ENV['OPENSHIFT_DATA_DIR']}redis/redis.sock", :namespace => 'sidekiq'  }
else
  REDIS_CONFIG = { :url => ENV['REDIS_URL'], :namespace => 'sidekiq'  }
end

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIG
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  user == "sidekiqadmin" && password == "dingdongdiddly"
end
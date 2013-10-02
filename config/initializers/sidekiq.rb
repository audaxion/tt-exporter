require 'sidekiq/web'

REDIS_CONFIG = { :url => "unix:///#{ENV['OPENSHIFT_DATA_DIR']}redis/redis.sock", :namespace => 'sidekiq'  }

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG
  config.options = config.options.merge({
      concurrency: 5
  })
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
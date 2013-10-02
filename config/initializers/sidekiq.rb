require 'sidekiq/web'

REDIS_CONFIG = { :url => "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['OPENSHIFT_REDIS_HOST']}:#{ENV['OPENSHIFT_REDIS_PORT']}/12", :namespace => 'sidekiq'  }

Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['OPENSHIFT_REDIS_HOST']}:#{ENV['OPENSHIFT_REDIS_PORT']}/12", :namespace => 'sidekiq'  }
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
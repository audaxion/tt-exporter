if Rails.env == 'production'
  $redis = Redis.new(:path => "#{ENV['OPENSHIFT_DATA_DIR']}redis/redis.sock")
else
  $redis = Redis.new(:url => ENV['REDIS_URL'])
end

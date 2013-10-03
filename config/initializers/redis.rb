if ENV['RAILS_ENV'] == 'production' || Rails.env == 'production'
  puts "Connecting to production redis"
  $redis = Redis.new(:path => "#{ENV['OPENSHIFT_DATA_DIR']}redis/redis.sock")
else
  puts "Connecting to dev/test redis"
  $redis = Redis.new(:url => ENV['REDIS_URL'])
end

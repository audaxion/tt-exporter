if ENV['RAILS_ENV'] == 'production' || Rails.env == 'production'
  puts "Connecting to production redis"
  $redis_config = {:path => "#{ENV['OPENSHIFT_DATA_DIR']}redis/redis.sock"}
else
  puts "Connecting to dev/test redis"
  $redis_config = {:url => ENV['REDIS_URL']}
end

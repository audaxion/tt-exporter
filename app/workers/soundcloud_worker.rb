class SoundcloudWorker
  include Sidekiq::Worker

  def perform(user_id, playlist_id, tt_songs)
    redis = Redis.new($redis_config)
    redis.set "jobs_remaining_#{playlist_id}", tt_songs.count

    tt_songs.each do |tt_id|
      SongWorker.perform_async(user_id, playlist_id, tt_id)
    end

  end
end
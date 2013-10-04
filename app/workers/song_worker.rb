class SongWorker
  include Sidekiq::Worker

  def perform(user_id, playlist_id, tt_id)
    user = User.find(BSON::ObjectId.from_string(user_id))
    playlist = user.playlists.find(BSON::ObjectId.from_string(playlist_id))
    song = Song.find_or_create_by(tt_id: tt_id)
    playlist.songs << song unless playlist.songs.find(song.id)
    playlist.save!

    if !song.processed
      uri = URI("http://turntable.fm/link/?fileid=#{tt_id}&site=soundcloud")
      response = Net::HTTP.get_response(uri)
      if response.code == '302'
        song_url = response['Location']
        client = Soundcloud.new(:client_id => ENV['SC_APP_ID'])
        track = client.get('/resolve', :url => song_url)
        song.sc_id = track.id
        song.processed = true
        song.save!
      end
    end

    redis = Redis.new($redis_config)
    batch_count = redis.get("jobs_remaining_#{playlist_id}")
    if batch_count.to_i > 1
      batch_count = redis.decr("jobs_remaining_#{playlist_id}")
      puts "JOBS LEFT :::::::::::::::::::::::> #{batch_count}"
    else
      tracks = playlist.songs.pluck(:sc_id).map { |song| {:id => song} }
      PlaylistWorker.perform_async(user_id, playlist_id, tracks, 0)
    end
  end
end
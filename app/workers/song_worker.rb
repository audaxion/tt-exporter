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
    batch_count = redis.decr("jobs_remaining_#{playlist_id}")
    puts "JOBS LEFT :::::::::::::::::::::::> #{batch_count}"
    if batch_count < 1
      redis.del "jobs_remaining_#{playlist_id}"
      tracks = playlist.songs.pluck(:sc_id).map { |song| {:id => song} }

      client = Soundcloud.new(:access_token => user.access_token)
      puts "CLIENT:::::::::::::::::::::::::>#{client.to_s}"
      if playlist.sc_playlist_id.blank?

        sc_playlist = client.post('/playlists', :playlist => {
            :title => playlist.name,
            :sharing => 'public',
            :tracks => tracks.slice!(0, 500)
        })

        count = 1
        while tracks.count > 0
          puts "TRACK COUNT:::::::::::>#{tracks.count}"
          client.post('/playlists', :playlist => {
              :title => "#{playlist.name} __#{count}",
              :sharing => 'public',
              :tracks => tracks.slice!(0, 500)
          })
        end

        playlist.sc_playlist_id = sc_playlist.id
      else
        sc_playlist = client.get("/me/playlists/#{playlist.sc_playlist_id}")
        track_ids = sc_playlist.tracks.map(&:id)
        track_ids << tracks

        count = 1
        while track_ids.count > 0
          if count == 1
            client.put(sc_playlist.uri, :playlist => {
                :tracks => track_ids.slice!(0, 500)
            })
          else
            client.post('/playlists', :playlist => {
                :title => "#{playlist.name} __#{count}",
                :sharing => 'public',
                :tracks => track_ids.slice!(0, 500)
            })
          end
        end
      end

      playlist.processing = false
      playlist.save!
    end
  end
end
class SoundcloudWorker
  include Sidekiq::Worker

  def perform(user_id, playlist_id, tt_songs)
    redis = Redis.new
    redis.set "jobs_remaining_#{playlist_id}", tt_songs.count

    tt_songs.each do |tt_id|
      SongWorker.perform_async(user_id, playlist_id, tt_id)
    end

=begin
    begin
      redis.subscribe("batch_complete_#{playlist_id}") do |on|
        on.message do |event, data|
          redis.del "jobs_remaining_#{playlist_id}"

          user = User.find(BSON::ObjectId.from_string(user_id))
          playlist = user.playlists.find(BSON::ObjectId.from_string(playlist_id))
          playlist.processed = true
          playlist.save!
          user.save!

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
            playlist.save!
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

          raise playlist_id
        end
      end
    rescue => error
      if error.message == playlist_id
        puts "Playlist #{playlist_id} for User #{user_id} is complete!"
      else
        puts "Error: #{error.message}, Status Code: #{error.response.code}"
        raise error
      end
    end
=end
  end
end
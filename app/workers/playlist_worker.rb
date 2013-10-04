class PlaylistWorker
  include Sidekiq::Worker

  def perform(user_id, playlist_id, tracks, iteration)
    user = User.find(BSON::ObjectId.from_string(user_id))
    playlist = user.playlists.find(BSON::ObjectId.from_string(playlist_id))
    internal_tracks = tracks

    client = Soundcloud.new(:access_token => user.access_token)
    puts "CLIENT:::::::::::::::::::::::::>#{client.to_s}"
    puts "TRACK COUNT:::::::::::>#{internal_tracks.count}"

    playlist_name = playlist.name
    if iteration > 0
      playlist_name = "#{playlist_name} __#{iteration}"
    end

    client.post('/playlists', :playlist => {
        :title => playlist_name,
        :sharing => 'public',
        :tracks => internal_tracks.slice!(0, 500)
    })

    if internal_tracks.count > 0
      PlaylistWorker.perform_async(user_id, playlist_id, internal_tracks, iteration+1)
    else
      playlist.processing = false
      playlist.save!
      redis = Redis.new($redis_config)
      redis.del "jobs_remaining_#{playlist_id}"
    end
  end
end
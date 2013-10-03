class ExportController < ApplicationController
  before_filter :authenticate_user!

  def index
    @processing_playlists = current_user.playlists.where(processing: true).all || []
  end

  def sc_playlists
    playlists = sc_client.get("/me/playlists").map { |playlist| {id: playlist.id, title: playlist.title}}
    render json: playlists
  end

  def process_turntable_playlist
    playlist_name = params[:playlist_name]
    begin
      tt_songs = ActiveSupport::JSON.decode(params[:songs])

      if tt_songs.blank?
        redirect_to export_path, :alert => 'You need to enter songs to export!'
        return
      end

      if playlist_name.blank?
        redirect_to export_path, :alert => 'Playlist Name cannot be blank!'
        return
      end
    rescue
      redirect_to export_path, :alert => 'There was a problem loading the turntable.fm songs. Make sure you enter the contents of the download file with no modifications.'
      return
    end

    playlist_id = params[:playlist] unless params[:playlist] == 'null'

    playlist = current_user.playlists.find_or_create_by(name: playlist_name, sc_playlist_id: playlist_id, total_songs: tt_songs.count, processing: true)
    unless current_user.valid?
      redirect_to export_path, :alert => "Error creating playlist #{playlist_name}. Make sure the name is unique!"
      return
    end
    current_user.save!

    $redis.set "jobs_remaining_#{playlist_id}", tt_songs.count
    SoundcloudWorker.perform_async(current_user.id.to_s, playlist.id.to_s, tt_songs)

    redirect_to export_path, :notice => "Processing #{tt_songs.count} song#{tt_songs.count>1?'s':''} into Soundcloud playlist #{playlist_name}. This might take a while. When the songs are done being processed they'll be added to your soundcloud account.", :playlist_id => playlist_id
  end

  def playlist_progress
    playlist = current_user.playlists.find(BSON::ObjectId.from_string(params[:playlist_id]))

    jobs_remaining = $redis.get("jobs_remaining_#{playlist.id.to_s}").to_i
    jobs_processed = playlist.total_songs - jobs_remaining
    progress = (jobs_processed.to_f / playlist.total_songs) * 100

    render text: sprintf("%0.02f", progress)
  end
end

class ExportController < ApplicationController
  before_filter :authenticate_user!

  def index
    @playlists = sc_client.get("/me/playlists")
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

    playlist = current_user.playlists.find_or_create_by(name: playlist_name, sc_playlist_id: playlist_id)
    unless current_user.valid?
      redirect_to export_path, :alert => "Error creating playlist #{playlist_name}. Make sure the name is unique!"
      return
    end
    current_user.save!

    SoundcloudWorker.perform_async(current_user.id.to_s, playlist.id.to_s, tt_songs)

    redirect_to export_path, :notice => "Processing #{tt_songs.count} song#{tt_songs.count>1?'s':''} into Soundcloud playlist #{playlist_name}. This might take a while. When the songs are done being processed they'll be added to your soundcloud account."
  end
end

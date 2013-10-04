class HomeController < ApplicationController
  def index
    @total_songs = Song.count
    redirect_to export_url if user_signed_in?
  end
end

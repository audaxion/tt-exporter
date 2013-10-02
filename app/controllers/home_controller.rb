class HomeController < ApplicationController
  def index
    redirect_to export_url if user_signed_in?
  end
end

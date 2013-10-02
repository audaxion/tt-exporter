class SessionsController < ApplicationController
  def new
    redirect_to '/auth/soundcloud'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid']).first

    if (user.blank?)
      user = User.create_with_omniauth(auth)
    else
      if auth['info']
        user.name = auth['info']['name'] || ""
        user.nickname = auth['info']['nickname'] || ""
        user.image_url = auth['info']['image'] || ""
      end
      if auth['credentials']
        user.access_token = auth['credentials']['token']
      end
      user.save!
    end

    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end
end

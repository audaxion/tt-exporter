class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :nickname, type: String
  field :access_token, type: String
  field :image_url, type: String
  embeds_many :playlists

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
        user.nickname = auth['info']['nickname'] || ""
        user.image_url = auth['info']['image'] || ""
      end
      if auth['credentials']
        user.access_token = auth['credentials']['token']
      end
    end
  end
  
  def update_with_omniauth(auth)
    if auth['info']
      self.name = auth['info']['name'] || ""
      self.nickname = auth['info']['nickname'] || ""
      self.image_url = auth['info']['image'] || ""
    end
    if auth['credentials']
      self.access_token = auth['credentials']['token']
    end
    self.save!
  end
end

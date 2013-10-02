class Playlist
  include Mongoid::Document
  validates_uniqueness_of :name
  validates :name, uniqueness: true

  field :name, type: String
  field :sc_playlist_id, type: String
  field :processed, type: Boolean
  has_and_belongs_to_many :songs, inverse_of: nil
  embedded_in :user
end

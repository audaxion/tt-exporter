class Song
  include Mongoid::Document
  validates_uniqueness_of :tt_id
  validates :tt_id, uniqueness: true

  field :tt_id, type: String
  field :sc_id, type: String
  field :processed, type: Boolean

  def self.create_with_tt_id(tt_id)
    create! do |song|
      song.tt_id = tt_id
      song.sc_id = nil
      song.processed = false
    end
  end
end

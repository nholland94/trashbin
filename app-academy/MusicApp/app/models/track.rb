class Track < ActiveRecord::Base
  attr_accessible :title, :lyrics, :album_id

  belongs_to :album
  has_many :notes
  
end

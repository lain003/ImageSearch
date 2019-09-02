# == Schema Information
#
# Table name: movies
#
#  id         :integer          not null, primary key
#  season_id  :integer
#  ep_num     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Movie < ApplicationRecord
  belongs_to :season
  has_many :meta_frames
end

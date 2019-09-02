# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  siry_id    :integer
#  serial     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Season < ApplicationRecord
  belongs_to :siry
  has_many :movies
end

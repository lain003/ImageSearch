# == Schema Information
#
# Table name: siries
#
#  id         :integer          not null, primary key
#  name       :string
#  identifier :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Siry < ApplicationRecord
  has_many :seasons
end

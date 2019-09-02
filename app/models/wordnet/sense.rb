# == Schema Information
#
# Table name: sense
#
#  synset :text
#  wordid :integer
#  lang   :text
#  rank   :text
#  lexid  :integer
#  freq   :integer
#  src    :text
#

class Sense  < ApplicationRecord
  establish_connection(:wordnet)
  self.table_name = 'sense'

  # @return [Word]
  def word
    Word.where(:wordid => self.wordid).first
  end
end

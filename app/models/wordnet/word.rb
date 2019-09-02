# == Schema Information
#
# Table name: word
#
#  wordid :integer          primary key
#  lang   :text
#  lemma  :text
#  pron   :text
#  pos    :text
#

class Word  < ApplicationRecord
  establish_connection(:wordnet)
  self.table_name = 'word'
end

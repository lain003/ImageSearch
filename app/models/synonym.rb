# @base_word [string]
# @synonym_words [Array<string>]
class Synonym
  attr_accessor :base_word,:synonym_words

  def initialize(base_word, synonym_words=nil)
    self.base_word = base_word
    self.synonym_words = synonym_words
  end

  # @param word [string]
  # @return [Synonym]
  def self.search_synonym(base_word)
    words = Word.where(:lemma => base_word,:lang => "jpn")
    senses1 = Sense.where(:wordid => words.map{|i| i.wordid})
    senses2 = Sense.where(:synset=>senses1.map{|i| i.synset})
    words = Word.where(:wordid => senses2.map{|i| i.wordid},:lang => "jpn")
    synonyms = words.map{|i| i.lemma}
    synonym_words = synonyms.uniq
    synonym_words = synonym_words.delete_if{|word| word == base_word }
    Synonym.new(base_word,synonym_words)
  end

  # @param word [string]
  # @param kuromoji_ins [Kuromoji::Core]
  # @return [Array<Synonym>]
  def self.get_synonym_and_tokenize(word,kuromoji_ins=nil)
    if kuromoji_ins.nil?
      kuromoji_ins = Kuromoji::Core.new
    end
    tokens = kuromoji_ins.tokenize(word)
    synonyms = []
    tokens.each do |_, val|
      val = val.split(",")
      word_class = val[0]
      if word_class.in?(%w(助詞))
        next
      end

      base = val[6]
      if word_class.in?(%w(感動詞 助動詞))
        synonyms << Synonym.new(base)
      else
        synonyms << Synonym.search_synonym(base)
      end
    end
    return synonyms
  end
end
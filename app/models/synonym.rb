# frozen_string_literal: true

# @base_word [string]
# @synonym_words [Array<string>]
class Synonym
  attr_accessor :base_word, :synonym_words

  def initialize(base_word, synonym_words = nil)
    self.base_word = base_word
    self.synonym_words = synonym_words
  end

  # @param word [string]
  # @return [Synonym]
  def self.search_synonym(base_word)
    words = Word.where(lemma: base_word, lang: 'jpn')
    senses1 = Sense.where(wordid: words.map(&:wordid))
    senses2 = Sense.where(synset: senses1.map(&:synset))
    words = Word.where(wordid: senses2.map(&:wordid), lang: 'jpn')
    synonyms = words.map(&:lemma)
    synonym_words = synonyms.uniq
    synonym_words = synonym_words.delete_if { |word| word == base_word }
    Synonym.new(base_word, synonym_words)
  end

  # @param word [string]
  # @param kuromoji_ins [Kuromoji::Core]
  # @return [Array<Synonym>]
  def self.get_synonym_and_tokenize(word, mecab = nil)
    synonyms = []

    mecab = Natto::MeCab.new if mecab.nil?
    mecab.parse(word) do |parse_word|
      next if parse_word.stat != 0

      val = parse_word.feature.split(',')
      word_class = val[0]
      base = val[6]

      next if word_class.in?(%w[助詞])

      synonyms << if word_class.in?(%w[感動詞 助動詞])
                    Synonym.new(base)
                  else
                    Synonym.search_synonym(base)
                  end
    end
    synonyms
  end
end

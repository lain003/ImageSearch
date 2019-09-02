require 'rails_helper'

RSpec.describe Synonym do
  describe 'search_synonym' do
    let(:search_word) { '機嫌' }
    subject { Synonym.search_synonym(search_word) }

    it 'BaseWordが設定されている' do
      expect(subject.base_word).to eq search_word
    end

    it '類義語が取得できる' do
      expect(subject.synonym_words).to match_array(%w[御機嫌 気分 ご機嫌])
    end
  end

  describe 'get_synonym_and_tokenize' do
    subject { Synonym.get_synonym_and_tokenize('庭には二羽、鶏がいる') }

    it '文章を形態素解析して助詞を外して、Synonymのインスタンスを返す' do
      expect { subject.map(&:base_word) }.to match_array(%w[庭 二 羽 、 鶏 いる])
    end
  end
end
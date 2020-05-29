require 'rails_helper'

RSpec.describe MetaFrame, type: :model, elasticsearch: true do
  let!(:meta_frame) { create :meta_frame, text: '機嫌' }
  let(:search_word) { '機嫌' }

  describe '__elasticsearch__.search' do
    subject { MetaFrame.__elasticsearch__.search(search_word) }

    it '検索できる' do
      expect(subject.records).to include meta_frame
    end

    context '登録されていない言葉で検索した時' do
      let(:search_word) { 'こんばんわ' }

      it '該当なし' do
        expect(subject.records).not_to include meta_frame
      end
    end
  end

  describe 'search' do
    let(:synonym) { Synonym.new(search_word) }

    subject { MetaFrame.search([synonym]) }

    it '検索できる' do
      expect(subject.records).to include meta_frame
    end

    context '類義語が設定されている時' do
      let(:synonym_word) { '気分' }
      let(:synonym) { Synonym.new(search_word, [synonym_word]) }
      let!(:synonym_meta_frame) { create :meta_frame, text: synonym_word }

      it '類義語も検索対象になる' do
        expect(subject.records).to include meta_frame, synonym_meta_frame
      end

      it 'ベースワードの方が類義語よりもスコアが高い' do
        results = subject.results
        base_score = results.select { |a| a['_id'] == meta_frame.id.to_s }.first['_score']
        synonym_score = results.select { |a| a['_id'] == synonym_meta_frame.id.to_s }.first['_score']
        expect(base_score).to be >= synonym_score
      end
    end
  end

  describe 'synonym_search' do
    let(:synonym) { Synonym.new(search_word) }
    let(:synonym_word) { '気分' }
    let!(:synonym_meta_frame) { create :meta_frame, text: synonym_word }

    subject { MetaFrame.synonym_search([search_word]) }

    it '検索すると類義語の検索結果も返ってくる事' do
      expect(subject.records).to include meta_frame, synonym_meta_frame
    end
  end
end
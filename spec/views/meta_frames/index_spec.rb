# frozen_string_literal: true

require 'rails_helper'
require 'google/cloud/storage'

RSpec.describe 'MetaFramesIndex', type: :system, elasticsearch: true do
  let!(:meta_frame_welcome) { create :meta_frame, text: '了解' }
  let!(:meta_frame_hello) { create :meta_frame, text: 'こんにちは' }

  before do
    allow_any_instance_of(MetaFrame).to receive(:image_url)
      .and_return('/test/sample.jpg')
    allow_any_instance_of(MetaFrame).to receive(:gif_url)
      .and_return('/test/sample.gif')

    visit meta_frames_index_path
  end

  it 'デフォルトでは「了解」の検索結果が表示される' do
    aggregate_failures do
      expect(all('.meta-frame').count).to eq 1
      expect(all('.meta-frame').first['test_data']).to eq meta_frame_welcome.id.to_s
    end
  end

  it '画像をクリックするとGifが拡大表示される' do
    find('img.anime').click
    expect(page).to have_css('.popup_inner img')
  end

  it '検索ボックスに単語を入力すると検索できる' do
    fill_in 'words', with: 'こんにちは'
    click_button 'Search'
    expect(find('.meta-frame')['test_data']).to eq meta_frame_hello.id.to_s
  end

  it 'Twitterアイコンを押すと、イメージとGifを共有するボタンが出る' do
    image_url = "https://twitter.com/share?text=&url=http://127.0.0.1/meta_frames/#{meta_frame_welcome.id}"
    gif_url = "https://twitter.com/share?text=&url=http://127.0.0.1/meta_frames/#{meta_frame_welcome.id}/gif"
    find('.twitter-icon').click
    aggregate_failures do
      expect(all('ul.type_choice a')[0]['href']).to eq image_url
      expect(all('ul.type_choice a')[1]['href']).to eq gif_url
    end
  end

  context 'データが21件あるとき' do
    before { create_list(:meta_frame, 20, text: '了解') }

    it '最後までスクロールすると、データが追加される' do
      visit meta_frames_index_path

      expect do
        page.execute_script 'window.scrollBy(0,$(document).height())'
        wait_for_block { all('.meta-frame')[20] }
      end.to change {
        page.find_all('.meta-frame').count
      }.from(20).to(21)
    end
  end
end

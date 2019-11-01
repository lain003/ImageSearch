require 'rails_helper'
require 'google/cloud/storage'

RSpec.feature 'MetaFramesIndex', type: :system, js: true, elasticsearch: true do
  let!(:meta_frame_welcome) { create :meta_frame, text: 'ようこそ' }
  let!(:meta_frame_hello) { create :meta_frame, text: 'こんにちは' }


  after(:each) do
    storage = Google::Cloud::Storage.new(project_id: Settings.gcp_project_id,
                                         credentials: Settings.gcp_credentials)
    bucket = storage.bucket Settings.bucket_name
    meta_frame_welcome.delete_gif(bucket)
    meta_frame_welcome.delete_image(bucket)
    meta_frame_hello.delete_gif(bucket)
    meta_frame_hello.delete_image(bucket)
  end

  before(:each) do
    storage = Google::Cloud::Storage.new(project_id: Settings.gcp_project_id,
                                         credentials: Settings.gcp_credentials)
    bucket = storage.bucket Settings.bucket_name
    meta_frame_welcome.upload_image('spec/support/file/sample.jpg', bucket)
    meta_frame_welcome.upload_gif('spec/support/file/sample.gif', bucket)
    meta_frame_hello.upload_image('spec/support/file/sample.jpg', bucket)
    meta_frame_hello.upload_gif('spec/support/file/sample.gif', bucket)

    visit meta_frames_index_path
  end

  scenario 'デフォルトでは「ようこそ」の検索結果が表示される' do
    expect(all('.meta-frame').count).to eq 1
    expect(all('.meta-frame').first['test_data']).to eq meta_frame_welcome.id.to_s
  end

  scenario '画像をクリックするとGifが拡大表示される' do
    find('img.anime').click
    expect(page).to have_css('.popup_inner img')
  end

  scenario '検索ボックスに単語を入力すると検索できる' do
    fill_in 'words', with: 'こんにちは'
    click_button 'Search'
    expect(find('.meta-frame')['test_data']).to eq meta_frame_hello.id.to_s
  end

  scenario 'Twitterアイコンを押すと、イメージとGifを共有するボタンが出る' do
    image_url = 'https://twitter.com/share?text=&url=http://127.0.0.1/meta_frames/' +
                meta_frame_welcome.id.to_s
    gif_url = 'https://twitter.com/share?text=&url=http://127.0.0.1/meta_frames/' +
              meta_frame_welcome.id.to_s + '/gif'
    find('.twitter-icon').click
    expect(all('ul.type_choice a')[0]['href']).to eq image_url
    expect(all('ul.type_choice a')[1]['href']).to eq gif_url
  end
end
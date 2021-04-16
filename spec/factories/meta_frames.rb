# frozen_string_literal: true

FactoryBot.define do
  factory :meta_frame do
    movie
    start_sec { 1 }
    end_sec { 2 }
    text { Faker::Lorem.words }
    image_num { 1 }

    trait :upload_image do
      after(:create) do |meta_frame|
        storage = Google::Cloud::Storage.new(project_id: Settings.gcp_project_id,
                                             credentials: Settings.gcp_credentials)
        bucket = storage.bucket Settings.bucket_name
        meta_frame.upload_image('spec/support/file/sample.jpg', bucket)
        meta_frame.upload_gif('spec/support/file/sample.gif', bucket)
      end
    end

    after(:create) do |_|
      MetaFrame.import refresh: true
    end
  end
end

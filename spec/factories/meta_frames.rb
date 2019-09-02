# frozen_string_literal: true

FactoryBot.define do
  after(:create) do |_|
    MetaFrame.import refresh: true
  end

  factory :meta_frame do
    movie
    start_sec { 1 }
    end_sec { 2 }
    text { Faker::Lorem.words }
  end
end

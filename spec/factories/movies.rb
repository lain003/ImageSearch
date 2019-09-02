FactoryBot.define do
  factory :movie do
    season
    sequence(:ep_num)
  end
end
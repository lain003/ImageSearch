FactoryBot.define do
  factory :siry do
    name { Faker::Name.name }
    identifier { Faker::Name.unique.name }
  end
end
FactoryBot.define do
  factory :choice do
    question
    label { Faker::Lorem.sentence(word_count: 3) }
  end
end

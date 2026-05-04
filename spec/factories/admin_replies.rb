FactoryBot.define do
  factory :admin_reply do
    association :answer
    association :user
    reply_text { Faker::Lorem.paragraph(sentence_count: 2) }
    status { :draft }
  end
end

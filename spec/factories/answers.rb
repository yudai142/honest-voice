FactoryBot.define do
  factory :answer do
    question
    user { nil }
    choice { nil }
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    session_id { SecureRandom.hex(16) }
  end
end

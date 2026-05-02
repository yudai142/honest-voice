FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'member' }

    trait :admin do
      role { 'admin' }
    end

    trait :member do
      role { 'member' }
    end
  end

  factory :question do
    user
    title { Faker::Lorem.sentence(word_count: 5) }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    question_type { 'text' }
    status { 'draft' }
    deadline { 7.days.from_now }

    trait :text_type do
      question_type { 'text' }
    end

    trait :choice_type do
      question_type { 'choice' }
    end

    trait :rating_type do
      question_type { 'rating' }
    end

    trait :published do
      status { 'published' }
    end

    trait :closed do
      status { 'closed' }
    end
  end

  factory :choice do
    question
    label { Faker::Lorem.sentence(word_count: 3) }
  end

  factory :answer do
    question
    user { nil }
    choice { nil }
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    session_id { SecureRandom.hex(16) }
  end

  factory :answer_token do
    question
    expires_at { 30.days.from_now }

    transient do
      token_value { SecureRandom.hex(32) }
    end

    after(:build) do |answer_token, evaluator|
      answer_token.token = evaluator.token_value
    end
  end
end

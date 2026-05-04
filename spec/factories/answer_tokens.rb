FactoryBot.define do
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

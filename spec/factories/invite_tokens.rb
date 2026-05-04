# frozen_string_literal: true

FactoryBot.define do
  factory :invite_token do
    company
    creator { association :user }
    token { SecureRandom.hex(32) }
    status { :active }
    expires_at { 7.days.from_now }
    used_by { nil }
    used_at { nil }

    trait :used do
      status { :used }
      used_by { create(:user) }
      used_at { Time.current }
    end

    trait :expired do
      status { :expired }
      expires_at { 1.day.ago }
    end
  end
end

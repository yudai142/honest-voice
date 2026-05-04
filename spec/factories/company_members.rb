# frozen_string_literal: true

FactoryBot.define do
  factory :company_member do
    company
    user
    role { :member }

    trait :owner do
      role { :owner }
    end

    trait :manager do
      role { :manager }
    end

    trait :viewer do
      role { :viewer }
    end
  end
end

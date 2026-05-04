# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    owner_id { create(:user).id }
    visibility { :company_private }
    description { Faker::Lorem.sentence }

    trait :with_members do
      after(:create) do |company|
        create_list(:company_member, 3, company: company, role: :member)
      end
    end

    trait :company_public do
      visibility { :company_public }
    end
  end
end

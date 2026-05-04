FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    sequence(:name) { |n| "User #{n}" }
    notification_enabled { true }
    role { 'member' }

    trait :admin do
      role { 'admin' }
    end

    trait :member do
      role { 'member' }
    end
  end
end

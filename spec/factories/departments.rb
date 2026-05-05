# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    company
    sequence(:name) { |n| "部署 #{n}" }
  end
end

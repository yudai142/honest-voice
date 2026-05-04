# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_schedule do
    company
    question { nil }
    sequence(:name) { |n| "Recurring Schedule #{n}" }
    frequency { :monthly }
    status { :active }
    next_scheduled_at { Time.current }
    last_run_at { nil }
  end
end
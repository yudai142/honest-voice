# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_schedule do
    company
    question { nil }
    question_template { nil }
    sequence(:name) { |n| "Recurring Schedule #{n}" }
    frequency { :monthly }
    status { :active }
    target_scope { 'all' }
    next_scheduled_at { Time.current }
    last_run_at { nil }
  end
end
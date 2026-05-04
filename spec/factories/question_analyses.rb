# frozen_string_literal: true

FactoryBot.define do
  factory :question_analysis do
    question
    company { question.company }
    status { 'pending' }
    sentiment_summary { nil }
    keywords { nil }
    average_rating { 0.0 }
    total_responses { 0 }
    analyzed_at { nil }
  end
end
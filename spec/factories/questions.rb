FactoryBot.define do
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
end

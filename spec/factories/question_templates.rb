# frozen_string_literal: true

FactoryBot.define do
  factory :question_template do
    company
    sequence(:name) { |n| "テンプレート #{n}" }
    description { "定点観測用テンプレート" }
    template_type { :monthly }
    questions_data do
      [
        { title: "チームの雰囲気はどうですか？", body: "詳しく教えてください。", question_type: "text" }
      ].to_json
    end
  end
end

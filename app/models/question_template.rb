# frozen_string_literal: true

class QuestionTemplate < ApplicationRecord
  belongs_to :company
  has_many :recurring_schedules, dependent: :destroy

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :company_id }

  enum template_type: { monthly: 0, quarterly: 1, yearly: 2 }

  def questions_array
    questions_data.present? ? JSON.parse(questions_data) : []
  end

  def questions_array=(data)
    self.questions_data = data.to_json
  end
end

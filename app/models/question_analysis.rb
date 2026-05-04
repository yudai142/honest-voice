# frozen_string_literal: true

class QuestionAnalysis < ApplicationRecord
  belongs_to :question
  belongs_to :company

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :question_id, presence: true
  validates :company_id, presence: true
  validates :question_id, uniqueness: { scope: :company_id }
  validates :status, presence: true

  def keywords_array
    keywords.present? ? keywords.split(',').map(&:strip) : []
  end

  def keywords_array=(data)
    self.keywords = data.join(', ')
  end
end

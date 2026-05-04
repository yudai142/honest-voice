# frozen_string_literal: true

class QuestionAnalysis < ApplicationRecord
  belongs_to :question
  belongs_to :company

  validates :question_id, presence: true
  validates :company_id, presence: true
  validates :question_id, uniqueness: { scope: :company_id }

  def keywords_array
    keywords.present? ? keywords.split(',').map(&:strip) : []
  end

  def keywords_array=(data)
    self.keywords = data.join(', ')
  end
end

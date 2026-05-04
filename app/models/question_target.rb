# frozen_string_literal: true

class QuestionTarget < ApplicationRecord
  belongs_to :question
  belongs_to :targetable, polymorphic: true

  validates :question_id, presence: true
  validates :targetable, presence: true

  enum :target_type, { department: 0, member: 1, role_based: 2 }
end

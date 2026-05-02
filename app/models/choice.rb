class Choice < ApplicationRecord
  belongs_to :question, optional: false
  has_many :answers, dependent: :destroy

  validates :label, presence: true, uniqueness: { scope: :question_id }
end

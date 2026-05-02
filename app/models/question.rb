class Question < ApplicationRecord
  enum :question_type, { text: 'text', choice: 'choice', rating: 'rating' }
  enum :status, { draft: 'draft', published: 'published', closed: 'closed' }

  belongs_to :user, optional: false
  has_many :choices, dependent: :destroy
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :choices, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true
  validates :body, presence: true
  validates :question_type, presence: true, inclusion: { in: question_types.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }

  def published?
    status == 'published'
  end

  def draft?
    status == 'draft'
  end

  def closed?
    status == 'closed'
  end
end


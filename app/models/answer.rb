class Answer < ApplicationRecord
  belongs_to :question, optional: false
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :choice, optional: true
  has_many :admin_replies, dependent: :destroy

  validates :session_id, presence: true
  validate :validate_body_or_choice

  before_save :set_session_id_hash

  private

  def set_session_id_hash
    if session_id.present?
      self.session_id_hash = Digest::SHA256.hexdigest(session_id)
    end
  end

  def validate_body_or_choice
    question_type = question&.question_type

    case question_type
    when 'text'
      errors.add(:body, "can't be blank") if body.blank?
    when 'choice'
      errors.add(:choice_id, "can't be blank") if choice_id.blank?
    when 'rating'
      errors.add(:choice_id, "can't be blank") if choice_id.blank?
    end
  end
end

class AnswerToken < ApplicationRecord
  belongs_to :question, optional: false

  validates :token, presence: true, uniqueness: true

  before_create :generate_token

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def valid_token?
    !expired?
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32) if token.blank?
  end
end

# frozen_string_literal: true

class InviteToken < ApplicationRecord
  belongs_to :company
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :used_by, class_name: 'User', optional: true

  validates :company_id, presence: true
  validates :token, presence: true, uniqueness: true

  enum :status, { active: 0, used: 1, expired: 2 }

  before_validation :generate_token, on: :create
  before_save :set_expires_at

  scope :active, -> { where(status: :active) }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }

  def expired?
    expires_at && expires_at < Time.current
  end

  def valid_for_use?
    active? && !expired?
  end

  def mark_as_used(user = nil)
    update(status: :used, used_by: user, used_at: Time.current)
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end

  def set_expires_at
    self.expires_at ||= 7.days.from_now
  end
end

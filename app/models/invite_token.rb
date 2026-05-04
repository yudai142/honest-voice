# frozen_string_literal: true

class InviteToken < ApplicationRecord
  belongs_to :company
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :used_by, class_name: 'User', optional: true

  validates :company_id, presence: true
  validates :token, presence: true, uniqueness: true
  validates :max_uses, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :use_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  enum :status, { active: 0, used: 1, expired: 2 }

  before_validation :generate_token, on: :create
  before_save :set_expires_at

  scope :active, -> { where(status: :active) }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }

  def expired?
    return false unless expires_at

    expires_at < Time.current
  end

  def valid_for_use?
    active? && status == 'active' && !expired? && has_remaining_uses?
  end

  def mark_as_used(user = nil)
    self.use_count ||= 0
    self.use_count += 1
    self.used_by = user
    self.used_at = Time.current

    if max_uses.present? && use_count >= max_uses
      self.active = false
      self.status = :used
    end

    save!
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end

  def set_expires_at
    self.expires_at ||= 7.days.from_now
  end

  def has_remaining_uses?
    return true if max_uses.blank?

    use_count.to_i < max_uses
  end
end

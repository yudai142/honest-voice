# frozen_string_literal: true

class CompanyMember < ApplicationRecord
  belongs_to :company
  belongs_to :user

  validates :company_id, presence: true
  validates :user_id, presence: true
  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :company_id }

  enum :role, { owner: 0, manager: 1, member: 2, viewer: 3 }

  def owner?
    role == 'owner'
  end

  def manager?
    role == 'owner' || role == 'manager'
  end

  def can_invite?
    owner? || manager?
  end
end

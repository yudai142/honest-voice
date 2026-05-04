# frozen_string_literal: true

class Company < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_many :company_members, dependent: :destroy
  has_many :users, through: :company_members
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :question_templates, dependent: :destroy
  has_many :question_analyses, dependent: :destroy
  has_many :recurring_schedules, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :owner_id, presence: true

  enum :visibility, { company_private: 0, company_public: 1 }

  after_create :add_owner_as_member

  private

  def add_owner_as_member
    company_members.create(user_id: owner_id, role: :owner)
  end
end

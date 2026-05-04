# frozen_string_literal: true

class Department < ApplicationRecord
  belongs_to :company
  has_many :questions, dependent: :destroy
  has_many :company_members, dependent: :nullify

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :company_id }
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :company_members, dependent: :destroy
  has_many :companies, through: :company_members
  has_many :owned_companies, class_name: 'Company', foreign_key: 'owner_id', dependent: :destroy
  has_many :invite_tokens, foreign_key: 'creator_id', dependent: :destroy
  has_many :created_admin_replies, class_name: 'AdminReply', foreign_key: 'user_id', dependent: :destroy

  validates :email, presence: true, uniqueness: true
end

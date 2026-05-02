class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { member: 'member', admin: 'admin' }

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: roles.keys }

  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end
end

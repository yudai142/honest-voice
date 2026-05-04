# frozen_string_literal: true

class AdminReply < ApplicationRecord
  belongs_to :answer
  belongs_to :user

  validates :answer_id, presence: true
  validates :user_id, presence: true
  validates :reply_text, presence: true

  enum status: { draft: 0, published: 1, archived: 2 }
end

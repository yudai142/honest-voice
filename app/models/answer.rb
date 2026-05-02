class Answer < ApplicationRecord
  belongs_to :question, optional: false
  belongs_to :user, optional: true
  belongs_to :choice, optional: true

  validates :body, presence: true

  before_save :set_session_id_hash

  private

  def set_session_id_hash
    if session_id.present?
      self.session_id_hash = Digest::SHA256.hexdigest(session_id)
    end
  end
end

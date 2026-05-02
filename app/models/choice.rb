class Choice < ApplicationRecord
  belongs_to :question, optional: false
  has_many :answers, dependent: :destroy

  alias_attribute :text, :label

  validates :label, presence: true, uniqueness: { scope: :question_id }

  before_validation :map_text_to_label

  private

  def map_text_to_label
    self.label = text if text.present? && label.blank?
  end
end

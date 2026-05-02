require 'rails_helper'

describe Choice, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question).optional(false) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:choice) }

    it { is_expected.to validate_presence_of(:label) }
  end
end

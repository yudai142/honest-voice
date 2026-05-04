require 'rails_helper'

describe Question, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company).optional(false) }
    it { is_expected.to have_many(:choices).dependent(:destroy) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:question) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:question_type) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe '#published?' do
    it 'returns true when status is published' do
      question = build(:question, status: 'published')
      expect(question.published?).to be true
    end
  end

  describe '#draft?' do
    it 'returns true when status is draft' do
      question = build(:question, status: 'draft')
      expect(question.draft?).to be true
    end
  end

  describe '#closed?' do
    it 'returns true when status is closed' do
      question = build(:question, status: 'closed')
      expect(question.closed?).to be true
    end
  end
end


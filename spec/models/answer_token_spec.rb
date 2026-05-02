require 'rails_helper'

describe AnswerToken, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question).optional(false) }
  end

  describe 'validations' do
    subject { build(:answer_token) }

    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_uniqueness_of(:token) }
  end

  describe 'token generation' do
    let(:answer_token) { build(:answer_token) }

    it 'generates a token on create' do
      answer_token.save!
      expect(answer_token.token).to be_present
      expect(answer_token.token.length).to be >= 32
    end
  end

  describe '#expired?' do
    it 'returns false when expires_at is in the future' do
      answer_token = build(:answer_token, expires_at: Time.current + 1.day)
      expect(answer_token.expired?).to be false
    end

    it 'returns true when expires_at is in the past' do
      answer_token = build(:answer_token, expires_at: Time.current - 1.day)
      expect(answer_token.expired?).to be true
    end
  end

  describe '#valid_token?' do
    let(:answer_token) { create(:answer_token) }

    it 'returns true for valid non-expired token' do
      expect(answer_token.valid_token?).to be true
    end

    it 'returns false for expired token' do
      answer_token.update(expires_at: Time.current - 1.day)
      expect(answer_token.valid_token?).to be false
    end
  end
end

require 'rails_helper'

describe Answer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question).optional(false) }
    it { is_expected.to belong_to(:user).optional(true) }
    it { is_expected.to belong_to(:choice).optional(true) }
  end

  describe 'validations' do
    subject { build(:answer) }

    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'session_id hashing' do
    let(:answer) { build(:answer, session_id: 'test-session-123') }

    it 'hashes session_id before save' do
      answer.save!
      expect(answer.session_id_hash).not_to be_nil
      expect(answer.session_id_hash).not_to eq('test-session-123')
    end

    it 'creates consistent hash for same session_id' do
      session_id = 'test-session-456'
      answer1 = build(:answer, session_id: session_id)
      answer2 = build(:answer, session_id: session_id)

      answer1.save!
      answer2.save!

      expect(answer1.session_id_hash).to eq(answer2.session_id_hash)
    end
  end

  describe '#set_session_id_hash' do
    it 'hashes the session_id' do
      answer = build(:answer, session_id: 'abc123')
      answer.send(:set_session_id_hash)
      expect(answer.session_id_hash).to be_present
    end
  end
end

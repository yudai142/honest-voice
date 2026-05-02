require 'rails_helper'

describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }

    it 'does not allow duplicate email' do
      user1 = create(:user, email: 'test@example.com')
      user2 = build(:user, email: 'test@example.com')
      expect(user2).not_to be_valid
    end
  end

  describe '#admin?' do
    it 'returns true when role is admin' do
      user = build(:user, role: 'admin')
      expect(user.admin?).to be true
    end

    it 'returns false when role is not admin' do
      user = build(:user, role: 'member')
      expect(user.admin?).to be false
    end
  end

  describe '#member?' do
    it 'returns true when role is member' do
      user = build(:user, role: 'member')
      expect(user.member?).to be true
    end

    it 'returns false when role is not member' do
      user = build(:user, role: 'admin')
      expect(user.member?).to be false
    end
  end
end

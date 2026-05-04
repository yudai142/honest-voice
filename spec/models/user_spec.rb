require 'rails_helper'

describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:answers).dependent(:destroy) }
    it { is_expected.to have_many(:company_members).dependent(:destroy) }
    it { is_expected.to have_many(:companies).through(:company_members) }
    it { is_expected.to have_many(:owned_companies).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }

    it 'does not allow duplicate email' do
      user1 = create(:user, email: 'test@example.com')
      user2 = build(:user, email: 'test@example.com')
      expect(user2).not_to be_valid
    end
  end

  describe 'role' do
    it { is_expected.to validate_presence_of(:role) }

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

  describe 'company associations' do
    it { is_expected.to have_many(:company_members).dependent(:destroy) }
    it { is_expected.to have_many(:companies).through(:company_members) }
    it { is_expected.to have_many(:owned_companies).class_name('Company').dependent(:destroy) }
  end
end

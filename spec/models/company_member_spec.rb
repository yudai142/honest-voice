# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyMember, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:company_member) }

    it { is_expected.to validate_presence_of(:company_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:role) }

    it 'validates uniqueness of user_id scoped to company_id' do
      company_member = create(:company_member)
      duplicate = build(:company_member, company_id: company_member.company_id, user_id: company_member.user_id)

      expect(duplicate).not_to be_valid
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(owner: 0, manager: 1, member: 2, viewer: 3) }
  end

  describe 'instance methods' do
    let(:company_member) { create(:company_member) }

    describe '#owner?' do
      it 'returns true if role is owner' do
        company_member.update(role: :owner)
        expect(company_member.owner?).to be true
      end

      it 'returns false if role is not owner' do
        company_member.update(role: :member)
        expect(company_member.owner?).to be false
      end
    end

    describe '#manager?' do
      it 'returns true if role is manager or higher' do
        company_member.update(role: :manager)
        expect(company_member.manager?).to be true
      end
    end

    describe '#can_invite?' do
      it 'returns true for owner and manager' do
        company_member.update(role: :owner)
        expect(company_member.can_invite?).to be true

        company_member.update(role: :manager)
        expect(company_member.can_invite?).to be true
      end

      it 'returns false for member and viewer' do
        company_member.update(role: :member)
        expect(company_member.can_invite?).to be false

        company_member.update(role: :viewer)
        expect(company_member.can_invite?).to be false
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:company_members).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:company_members) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
    it { is_expected.to have_many(:invite_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:departments).dependent(:destroy) }
    it { is_expected.to have_many(:question_templates).dependent(:destroy) }
    it { is_expected.to have_many(:question_analyses).dependent(:destroy) }
    it { is_expected.to have_many(:recurring_schedules).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:owner_id) }
    it { is_expected.to belong_to(:owner).class_name('User') }

    it 'validates name length' do
      company = build(:company, name: 'a' * 256)
      expect(company).not_to be_valid
    end

    it 'allows valid company' do
      company = build(:company)
      expect(company).to be_valid
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:visibility).with_values(private: 0, public: 1) }
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates owner as company_member' do
        user = create(:user)
        company = create(:company, owner_id: user.id)

        expect(company.company_members.count).to eq(1)
        expect(company.company_members.first.user_id).to eq(user.id)
        expect(company.company_members.first.role).to eq('owner')
      end
    end
  end

  describe 'instance methods' do
    let(:company) { create(:company) }

    describe '#add_member' do
      it 'adds a user as a member' do
        user = create(:user)
        company.add_member(user, 'member')

        expect(company.users).to include(user)
        member = company.company_members.find_by(user_id: user.id)
        expect(member.role).to eq('member')
      end
    end

    describe '#owner' do
      it 'returns the owner user' do
        expect(company.owner).to be_a(User)
        expect(company.owner.id).to eq(company.owner_id)
      end
    end

    describe '#members' do
      it 'returns all company members' do
        create_list(:company_member, 3, company: company)
        expect(company.company_members.count).to eq(4) # owner + 3 members
      end
    end
  end
end

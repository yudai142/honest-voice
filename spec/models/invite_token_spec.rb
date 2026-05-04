# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InviteToken, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:creator).class_name('User').optional }
  end

  describe 'validations' do
    subject { build(:invite_token) }

    it { is_expected.to validate_presence_of(:company_id) }
    it { is_expected.to validate_presence_of(:token) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, used: 1, expired: 2) }
  end

  describe 'callbacks' do
    describe 'before_create' do
      it 'generates unique token' do
        invite_token = build(:invite_token)
        expect(invite_token.token).to be_nil
        invite_token.save
        expect(invite_token.token).not_to be_nil
        expect(invite_token.token.length).to be >= 32
      end
    end

    describe 'before_save' do
      it 'sets expires_at if not provided' do
        invite_token = build(:invite_token, expires_at: nil)
        invite_token.save
        expect(invite_token.expires_at).not_to be_nil
        expect(invite_token.expires_at).to be > Time.current
      end
    end
  end

  describe 'scopes' do
    let(:company) { create(:company) }

    describe '.active' do
      it 'returns only active tokens' do
        active = create(:invite_token, company: company, status: :active)
        used = create(:invite_token, company: company, status: :used)
        expired = create(:invite_token, company: company, status: :expired)

        expect(InviteToken.active).to include(active)
        expect(InviteToken.active).not_to include(used)
        expect(InviteToken.active).not_to include(expired)
      end
    end

    describe '.not_expired' do
      it 'returns tokens not past expires_at' do
        valid = create(:invite_token, company: company, expires_at: 1.day.from_now)
        expired = create(:invite_token, company: company, expires_at: 1.day.ago)

        expect(InviteToken.not_expired).to include(valid)
        expect(InviteToken.not_expired).not_to include(expired)
      end
    end
  end

  describe 'instance methods' do
    let(:invite_token) { create(:invite_token) }

    describe '#expired?' do
      it 'returns true if expires_at is in the past' do
        invite_token.update(expires_at: 1.day.ago)
        expect(invite_token.expired?).to be true
      end

      it 'returns false if expires_at is in the future' do
        invite_token.update(expires_at: 1.day.from_now)
        expect(invite_token.expired?).to be false
      end
    end

    describe '#valid_for_use?' do
      it 'returns true only if active and not expired' do
        invite_token.update(status: :active, expires_at: 1.day.from_now)
        expect(invite_token.valid_for_use?).to be true

        invite_token.update(status: :used)
        expect(invite_token.valid_for_use?).to be false

        invite_token.update(status: :active, expires_at: 1.day.ago)
        expect(invite_token.valid_for_use?).to be false
      end
    end

    describe '#mark_as_used' do
      it 'updates status to used' do
        invite_token.mark_as_used
        expect(invite_token.status).to eq('used')
      end
    end
  end
end

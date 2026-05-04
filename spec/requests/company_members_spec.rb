require 'rails_helper'

RSpec.describe 'CompanyMembers', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner) { create(:user, :admin) }
  let(:manager_user) { create(:user, :member) }
  let(:target_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: owner.id) }
  let!(:manager_member) { create(:company_member, company: company, user: manager_user, role: :manager) }
  let!(:target_member) { create(:company_member, company: company, user: target_user, role: :member) }

  describe 'GET /admin/companies/:company_id/company_members' do
    context 'owner ユーザー' do
      before { sign_in owner }

      it 'メンバー一覧を取得できる' do
        get "/admin/companies/#{company.id}/company_members"
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['members']).to be_an(Array)
        expect(json['members'].size).to be >= 2
      end
    end
  end

  describe 'PATCH /admin/companies/:company_id/company_members/:id' do
    context 'owner ユーザー' do
      before { sign_in owner }

      it 'ロール変更ができる' do
        patch "/admin/companies/#{company.id}/company_members/#{target_member.id}", params: {
          company_member: { role: :viewer }
        }

        expect(response).to have_http_status(:ok)
        expect(target_member.reload.role).to eq('viewer')
      end
    end

    context 'owner 以外のユーザー' do
      before { sign_in manager_user }

      it 'ロール変更できない' do
        patch "/admin/companies/#{company.id}/company_members/#{target_member.id}", params: {
          company_member: { role: :viewer }
        }

        expect(response).to have_http_status(:forbidden)
        expect(target_member.reload.role).to eq('member')
      end
    end
  end

  describe 'DELETE /admin/companies/:company_id/company_members/:id' do
    context 'owner ユーザー' do
      before { sign_in owner }

      it 'メンバー除外ができる' do
        expect do
          delete "/admin/companies/#{company.id}/company_members/#{target_member.id}"
        end.to change(CompanyMember, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'owner 以外のユーザー' do
      before { sign_in manager_user }

      it 'メンバー除外できない' do
        expect do
          delete "/admin/companies/#{company.id}/company_members/#{target_member.id}"
        end.not_to change(CompanyMember, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
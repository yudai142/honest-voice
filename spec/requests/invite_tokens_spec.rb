require 'rails_helper'

RSpec.describe 'InviteTokens', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:other_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: owner.id) }

  describe 'POST /admin/companies/:company_id/invite_tokens' do
    context 'admin 以上のユーザー' do
      before { sign_in owner }

      it '招待URL発行ができる' do
        expect do
          post "/admin/companies/#{company.id}/invite_tokens", params: { invite_token: { max_uses: 3 } }
        end.to change(InviteToken, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['invite_token']['token']).to be_present
      end
    end

    context '未認証ユーザー' do
      it 'ログインページへリダイレクトされる' do
        post "/admin/companies/#{company.id}/invite_tokens"
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /invite/:token' do
    let(:invite_token) { create(:invite_token, company: company, max_uses: 3, use_count: 0, active: true) }

    context '未ログインユーザー' do
      it 'ログイン画面へ遷移し、ログイン後参加を継続できる' do
        get "/invite/#{invite_token.token}"

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'ログイン後に招待URLへ復帰する' do
        get "/invite/#{invite_token.token}"

        post user_session_path, params: {
          user: {
            email: other_user.email,
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/invite/#{invite_token.token}")
      end
    end

    context '既存メンバー' do
      before do
        create(:company_member, company: company, user: member_user, role: :member)
        sign_in member_user
      end

      it '再参加せず質問一覧へ遷移する' do
        expect do
          get "/invite/#{invite_token.token}"
        end.not_to change(CompanyMember, :count)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to('/member/dashboard')
      end
    end

    context '未参加のログインユーザー' do
      before { sign_in other_user }

      it '会社へ参加し、use_countを更新する' do
        expect do
          get "/invite/#{invite_token.token}"
        end.to change(CompanyMember, :count).by(1)

        invite_token.reload
        expect(invite_token.use_count).to eq(1)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to('/member/dashboard')
      end
    end
  end
end
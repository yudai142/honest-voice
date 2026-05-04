require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }

  describe 'GET #index' do
    context 'when admin is signed in' do
      before { sign_in admin }

      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when member is signed in' do
      before { sign_in member }

      it 'redirects to member dashboard' do
        get :index
        expect(response).to redirect_to(member_dashboard_path)
      end
    end

    context 'when no user is signed in' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end



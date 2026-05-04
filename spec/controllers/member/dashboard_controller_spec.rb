require 'rails_helper'

RSpec.describe Member::DashboardController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }

  describe 'GET #index' do
    context 'when member is signed in' do
      before { sign_in member }

      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when admin is signed in' do
      before { sign_in admin }

      it 'redirects to admin dashboard' do
        get :index
        expect(response).to redirect_to(admin_dashboard_path)
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

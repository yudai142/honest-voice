require 'rails_helper'

RSpec.describe 'Devise Authentication', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }

  describe 'GET /users/sign_in' do
    it 'ログインページが表示される' do
      get '/users/sign_in'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Authentication Check' do
    it '認証なしでアクセスするとログインページにリダイレクト' do
      get '/admin/dashboard'
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'admin でログイン後、admin ダッシュボード にアクセスできる' do
      sign_in admin
      get '/admin/dashboard'
      expect(response).to have_http_status(:ok)
    end

    it 'member でログイン後、member ダッシュボードにアクセスできる' do
      sign_in member
      get '/member/dashboard'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Role-based Access Control' do
    it 'member が admin ダッシュボードにアクセスするとリダイレクト' do
      sign_in member
      get '/admin/dashboard'
      expect(response).to redirect_to('/member/dashboard')
    end

    it 'admin が member ダッシュボードにアクセスするとリダイレクト' do
      sign_in admin
      get '/member/dashboard'
      expect(response).to redirect_to('/admin/dashboard')
    end
  end

  describe 'Root Path Redirect' do
    it 'ログインしていない場合、ログインページにリダイレクト' do
      get '/'
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'admin がログインしている場合、admin ダッシュボードにリダイレクト' do
      sign_in admin
      get '/'
      expect(response).to redirect_to('/admin/dashboard')
    end

    it 'member がログインしている場合、member ダッシュボードにリダイレクト' do
      sign_in member
      get '/'
      expect(response).to redirect_to('/member/dashboard')
    end
  end
end

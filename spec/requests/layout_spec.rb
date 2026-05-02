require 'rails_helper'

RSpec.describe 'Navigation and Layout', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }

  describe 'Admin Navigation' do
    before { sign_in admin }

    it 'admin ダッシュボードにアクセスするとナビゲーションが表示される' do
      get '/admin/dashboard'
      expect(response.body).to include('admin-navbar')
    end

    it 'ログアウトリンクが表示される' do
      get '/admin/dashboard'
      expect(response.body).to include('Sign Out')
    end

    it 'ユーザー名が表示される' do
      get '/admin/dashboard'
      expect(response.body).to include(admin.email)
    end
  end

  describe 'Member Navigation' do
    before { sign_in member }

    it 'member ダッシュボードにアクセスするとナビゲーション が表示される' do
      get '/member/dashboard'
      expect(response.body).to include('member-navbar')
    end

    it 'ログアウトリンクが表示される' do
      get '/member/dashboard'
      expect(response.body).to include('Sign Out')
    end

    it 'ユーザー名が表示される' do
      get '/member/dashboard'
      expect(response.body).to include(member.email)
    end
  end

  describe 'Layout Structure' do
    it 'すべてのページに基本レイアウトが適用される' do
      sign_in admin
      get '/admin/dashboard'
      expect(response.body).to include('<html')
      expect(response.body).to include('<body')
      expect(response.body).to include('footer')
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

    it 'member がログインしている場合、member ダッシュボードにリダイレ クト' do
      sign_in member
      get '/'
      expect(response).to redirect_to('/member/dashboard')
    end
  end
end

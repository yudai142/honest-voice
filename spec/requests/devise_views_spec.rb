require 'rails_helper'

RSpec.describe 'Devise Views - DaisyUI Styling', type: :request do
  describe 'GET /users/sign_in' do
    it 'displays login page with DaisyUI styling' do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Honest Voice - ログイン')
      expect(response.body).to include('card')
      expect(response.body).to include('btn btn-primary')
      expect(response.body).to include('form-control')
    end

    it 'displays email and password fields' do
      get new_user_session_path

      expect(response.body).to include('email')
      expect(response.body).to include('password')
      expect(response.body).to include('placeholder')
    end

    it 'displays remember me checkbox' do
      get new_user_session_path

      expect(response.body).to include('ログイン状態を保持する')
      expect(response.body).to include('checkbox')
    end

    it 'displays signup and password reset links' do
      get new_user_session_path

      expect(response.body).to include('新規登録')
      expect(response.body).to include('パスワードをお忘れですか？')
    end
  end

  describe 'GET /users/sign_up' do
    it 'displays signup page with DaisyUI styling' do
      get new_user_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('card')
      expect(response.body).to include('btn btn-primary')
      expect(response.body).to include('form-control')
    end

    it 'displays email and password fields' do
      get new_user_registration_path

      expect(response.body).to include('email')
      expect(response.body).to include('password')
      expect(response.body).to include('password_confirmation')
    end

    it 'displays link to login page' do
      get new_user_registration_path

      expect(response.body).to include(new_user_session_path)
    end
  end

  describe 'GET /users/password/new' do
    it 'displays password reset page with DaisyUI styling' do
      get new_user_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('card')
      expect(response.body).to include('btn')
      expect(response.body).to include('form-control')
    end

    it 'displays email field' do
      get new_user_password_path

      expect(response.body).to include('email')
    end
  end
end

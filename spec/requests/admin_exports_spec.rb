# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Exports', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: admin_user.id) }
  let(:question) { create(:question, :text_type, company: company, status: 'published', title: 'テスト質問') }

  describe 'アクセス制御' do
    context '未認証ユーザー' do
      it 'PDF: ログインページにリダイレクトされる' do
        get "/admin/questions/#{question.id}/export/pdf"
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'CSV: ログインページにリダイレクトされる' do
        get "/admin/questions/#{question.id}/export/csv"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'memberユーザー' do
      before { sign_in member_user }

      it 'PDF: 403 Forbidden を返す' do
        get "/admin/questions/#{question.id}/export/pdf"
        expect(response).to have_http_status(:forbidden)
      end

      it 'CSV: 403 Forbidden を返す' do
        get "/admin/questions/#{question.id}/export/csv"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/questions/:id/export/pdf' do
    before do
      sign_in admin_user
      company # adminのcompanyを作成
      create_list(:answer, 3, question: question, body: 'テスト回答')
    end

    it 'PDF形式でダウンロードできる' do
      get "/admin/questions/#{question.id}/export/pdf"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/pdf')
    end

    it 'Content-Dispositionにattachmentが含まれる' do
      get "/admin/questions/#{question.id}/export/pdf"
      expect(response.headers['Content-Disposition']).to include('attachment')
    end

    it 'ファイル名に質問タイトルが含まれる' do
      get "/admin/questions/#{question.id}/export/pdf"
      expect(response.headers['Content-Disposition']).to include('.pdf')
    end

    context '別会社の質問' do
      let(:other_admin) { create(:user, :admin) }
      let(:other_company) { create(:company, owner_id: other_admin.id) }
      let(:other_question) { create(:question, company: other_company) }

      it '404 Not Found を返す' do
        get "/admin/questions/#{other_question.id}/export/pdf"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /admin/questions/:id/export/csv' do
    before do
      sign_in admin_user
      company # adminのcompanyを作成
      create_list(:answer, 3, question: question, body: 'CSV回答テスト')
    end

    it 'CSV形式でダウンロードできる' do
      get "/admin/questions/#{question.id}/export/csv"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/csv')
    end

    it 'Content-Dispositionにattachmentが含まれる' do
      get "/admin/questions/#{question.id}/export/csv"
      expect(response.headers['Content-Disposition']).to include('attachment')
    end

    it 'CSVにヘッダー行が含まれる' do
      get "/admin/questions/#{question.id}/export/csv"
      csv_body = response.body
      expect(csv_body).to include('回答')
    end

    it '回答データが含まれる' do
      get "/admin/questions/#{question.id}/export/csv"
      expect(response.body).to include('CSV回答テスト')
    end

    context '別会社の質問' do
      let(:other_admin) { create(:user, :admin) }
      let(:other_company) { create(:company, owner_id: other_admin.id) }
      let(:other_question) { create(:question, company: other_company) }

      it '404 Not Found を返す' do
        get "/admin/questions/#{other_question.id}/export/csv"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

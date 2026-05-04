require 'rails_helper'

RSpec.describe 'Security', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }

  describe 'SQL injection対策' do
    let(:question) { create(:question, :text_type, status: 'published') }

    it 'SQLインジェクション文字列を実行せず文字列として保存する' do
      sign_in admin_user
      payload = "'; DROP TABLE users; --"

      expect do
        post "/questions/#{question.id}/answers", params: {
          answer: {
            body: payload,
            session_id: 'security-session-1'
          }
        }
      end.to change(Answer, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Answer.last.body).to eq(payload)
      expect { User.count }.not_to raise_error
    end
  end

  describe 'CSRF対策' do
    it 'ApplicationController が verify_authenticity_token を有効化している' do
      callback_filters = ApplicationController._process_action_callbacks.map(&:filter)
      expect(callback_filters).to include(:verify_authenticity_token)
    end
  end

  describe 'XSS対策' do
    it '管理画面で質問本文をエスケープして表示する' do
      sign_in admin_user
      question = create(
        :question,
        user: admin_user,
        body: '<script>alert("xss")</script>'
      )

      get "/admin/questions/#{question.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;')
      expect(response.body).not_to include('<script>alert("xss")</script>')
    end
  end

  describe '匿名性検証' do
    it '回答一覧レスポンスに session_id を含めない' do
      question = create(:question)
      create(:answer, question: question, session_id: 'anon-session')

      get "/questions/#{question.id}/answers"
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      json['answers'].each do |answer|
        expect(answer).not_to have_key('session_id')
        expect(answer).not_to have_key('session_id_hash')
      end
    end
  end
end

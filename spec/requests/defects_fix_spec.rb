require 'rails_helper'

RSpec.describe 'Defects Fix Regression', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }

  describe '管理者質問画面テンプレート' do
    before { sign_in admin_user }

    let(:question) { create(:question, :published, user: admin_user) }

    it 'GET /admin/questions/new が表示できる' do
      get '/admin/questions/new'
      expect(response).to have_http_status(:ok)
    end

    it 'GET /admin/questions/:id/edit が表示できる' do
      get "/admin/questions/#{question.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'メンバー評価回答フロー' do
    before { sign_in member_user }

    let(:rating_question) { create(:question, :published, :rating_type) }

    it '評価質問画面に星評価入力が表示される' do
      get "/questions/#{rating_question.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('rating rating-lg')
      expect(response.body).to include('answer[rating_value]')
    end

    it 'rating_value を送信すると回答と選択肢が保存される' do
      expect do
        post "/questions/#{rating_question.id}/answers", params: {
          answer: {
            rating_value: '4',
            session_id: 'rating-flow-session-001'
          }
        }, format: :html
      end.to change(Answer, :count).by(1)

      expect(response).to redirect_to(member_dashboard_path)
      answer = Answer.last
      expect(answer.choice).to be_present
      expect(answer.choice.label).to eq('4')
      expect(answer.user).to eq(member_user)
    end
  end
end

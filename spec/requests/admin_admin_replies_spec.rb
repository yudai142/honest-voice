require 'rails_helper'

RSpec.describe 'Admin::AdminReplies', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: admin_user.id) }
  let(:question) { create(:question, :published, company: company) }
  let(:answer) { create(:answer, question: question, body: 'テスト回答') }

  describe 'アクセス制御' do
    context '未認証ユーザー' do
      it 'ログインページにリダイレクトされる' do
        get "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'memberユーザー' do
      before { sign_in member_user }

      it 'admin_replies にアクセスできない' do
        get "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'adminユーザー' do
      before { sign_in admin_user }

      it 'admin_replies にアクセスできる' do
        get "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies.json"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /admin/questions/:question_id/answers/:answer_id/admin_replies' do
    before { sign_in admin_user }

    context '返信がない場合' do
      it '空の配列を返す' do
        get "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies.json"
        json = JSON.parse(response.body)
        expect(json['admin_replies']).to be_an(Array)
        expect(json['admin_replies']).to be_empty
      end
    end

    context '返信がある場合' do
      before do
        create(:admin_reply, answer: answer, user: admin_user, reply_text: '対応します')
        create(:admin_reply, answer: answer, user: admin_user, reply_text: '確認しました')
      end

      it '返信一覧を返す' do
        get "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies.json"
        json = JSON.parse(response.body)
        expect(json['admin_replies'].length).to eq(2)
        expect(json['admin_replies'].first).to include('reply_text', 'status')
      end
    end
  end

  describe 'POST /admin/questions/:question_id/answers/:answer_id/admin_replies' do
    before { sign_in admin_user }

    let(:valid_params) do
      { admin_reply: { reply_text: '確認しました。対応します。', status: 'published' } }
    end

    context '正常なパラメータ' do
      it '返信が作成される' do
        expect {
          post "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies",
               params: valid_params, as: :json
        }.to change(AdminReply, :count).by(1)
      end

      it 'HTTP 201 を返す' do
        post "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies",
             params: valid_params, as: :json
        expect(response).to have_http_status(:created)
      end

      it '作成した返信を返す' do
        post "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies",
             params: valid_params, as: :json
        json = JSON.parse(response.body)
        expect(json['admin_reply']['reply_text']).to eq('確認しました。対応します。')
      end

      it 'admin_user が user として設定される' do
        post "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies",
             params: valid_params, as: :json
        expect(AdminReply.last.user).to eq(admin_user)
      end
    end

    context '不正なパラメータ' do
      it 'reply_text が空の場合はエラーを返す' do
        post "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies",
             params: { admin_reply: { reply_text: '' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'DELETE /admin/questions/:question_id/answers/:answer_id/admin_replies/:id' do
    before { sign_in admin_user }

    let!(:admin_reply) do
      create(:admin_reply, answer: answer, user: admin_user, reply_text: '削除テスト')
    end

    it '返信が削除される' do
      expect {
        delete "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies/#{admin_reply.id}",
               as: :json
      }.to change(AdminReply, :count).by(-1)
    end

    it 'HTTP 204 を返す' do
      delete "/admin/questions/#{question.id}/answers/#{answer.id}/admin_replies/#{admin_reply.id}",
             as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end

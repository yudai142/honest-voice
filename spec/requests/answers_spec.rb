require 'rails_helper'

RSpec.describe 'Answers API', type: :request do
  let(:user) { create(:user, :admin) }
  let(:question) { create(:question) }
  let(:choice) { create(:choice, question: question) }

  before { sign_in user }

  describe 'POST /questions/:question_id/answers' do
    context '正常な回答投稿' do
      let(:valid_params) do
        {
          answer: {
            body: '有益なフィードバックです',
            session_id: 'test-session-123',
            choice_id: choice.id
          }
        }
      end

      it '回答が作成される' do
        expect {
          post "/questions/#{question.id}/answers", params: valid_params
        }.to change(Answer, :count).by(1)
      end

      it 'セッション ID がハッシング化される' do
        post "/questions/#{question.id}/answers", params: valid_params
        answer = Answer.last
        expected_hash = Digest::SHA256.hexdigest('test-session-123')
        expect(answer.session_id_hash).to eq(expected_hash)
      end

      it 'HTTP 201 を返す' do
        post "/questions/#{question.id}/answers", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'JSON レスポンスで answer を返す' do
        post "/questions/#{question.id}/answers", params: valid_params
        expect(response.content_type).to include('application/json')
        json = JSON.parse(response.body)
        expect(json['answer']).to be_present
      end
    end

    context '重複防止チェック' do
      let(:session_id) { 'duplicate-session-456' }
      let(:valid_params) do
        {
          answer: {
            body: 'テスト回答',
            session_id: session_id,
            choice_id: choice.id
          }
        }
      end

      it '同じセッション ID での重複回答を防ぐ' do
        # 最初の回答
        post "/questions/#{question.id}/answers", params: valid_params

        # 重複回答を試みる
        expect {
          post "/questions/#{question.id}/answers", params: valid_params
        }.not_to change(Answer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it '異なる質問には別々の回答ができる' do
        question2 = create(:question)

        post "/questions/#{question.id}/answers", params: valid_params
        expect(response).to have_http_status(:created)

        post "/questions/#{question2.id}/answers", params: valid_params.merge(question_id: question2.id)
        expect(response).to have_http_status(:created)
      end
    end

    context '無記名回答（セッション ID のみ）' do
      let(:valid_params) do
        {
          answer: {
            body: '無記名フィードバック',
            session_id: 'anonymous-session-789'
          }
        }
      end

      it '無記名回答が作成される' do
        expect {
          post "/questions/#{question.id}/answers", params: valid_params
        }.to change(Answer, :count).by(1)
      end

      it 'user_id が nil のまま保存される' do
        post "/questions/#{question.id}/answers", params: valid_params
        answer = Answer.last
        expect(answer.user_id).to be_nil
      end
    end

    context 'バリデーション失敗' do
      it '空の body は受け付けない' do
        params = {
          answer: {
            body: '',
            session_id: 'test-session-123'
          }
        }

        expect {
          post "/questions/#{question.id}/answers", params: params
        }.not_to change(Answer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'session_id がないと失敗する' do
        params = {
          answer: {
            body: 'テスト回答'
          }
        }

        expect {
          post "/questions/#{question.id}/answers", params: params
        }.not_to change(Answer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it '存在しない question_id は 404 を返す' do
        params = {
          answer: {
            body: 'テスト回答',
            session_id: 'test-session-123'
          }
        }

        post '/questions/99999/answers', params: params
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'choice との紐付け' do
      let(:valid_params) do
        {
          answer: {
            body: '選択肢型の回答',
            session_id: 'choice-session-111',
            choice_id: choice.id
          }
        }
      end

      it 'choice_id が紐付く' do
        post "/questions/#{question.id}/answers", params: valid_params
        answer = Answer.last
        expect(answer.choice_id).to eq(choice.id)
      end

      it 'choice_id がない場合も記録される' do
        params = {
          answer: {
            body: 'テキスト型の回答',
            session_id: 'text-session-222'
          }
        }

        post "/questions/#{question.id}/answers", params: params
        answer = Answer.last
        expect(answer.choice_id).to be_nil
      end
    end
  end

  describe 'GET /questions/:question_id/answers' do
    before do
      create(:answer, question: question, body: '回答1')
      create(:answer, question: question, body: '回答2')
    end

      it '質問の回答一覧を取得できる' do
      get "/questions/#{question.id}/answers"
      expect(response).to have_http_status(:ok)
    end

    it 'JSON で回答データを返す' do
      get "/questions/#{question.id}/answers"
      json = JSON.parse(response.body)
      expect(json['answers']).to be_an(Array)
      expect(json['answers'].length).to eq(2)
    end

    it 'session_id_hash は返さない（プライバシー保護）' do
      get "/questions/#{question.id}/answers"
      json = JSON.parse(response.body)
      json['answers'].each do |answer|
        expect(answer).not_to have_key('session_id')
        expect(answer).not_to have_key('session_id_hash')
      end
    end
  end
end

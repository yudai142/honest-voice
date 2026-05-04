require 'rails_helper'

RSpec.describe 'Admin::Questions', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:question) { create(:question) }
  let(:choice) { create(:choice, question: question) }

  describe 'Access Control' do
    context 'admin user' do
      before { sign_in admin_user }

      it 'index にアクセスできる' do
        get '/admin/questions'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'member user' do
      before { sign_in member_user }

      it 'index にアクセスできない' do
        get '/admin/questions'
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'unauthenticated user' do
      it 'ログインページにリダイレクトされる' do
        get '/admin/questions'
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /admin/questions' do
    before do
      sign_in admin_user
      create_list(:question, 5)
    end

    it '質問一覧を表示する' do
      get '/admin/questions'
      expect(response).to have_http_status(:ok)
    end

    it 'JSON で質問リストを返す' do
      get '/admin/questions.json'
      json = JSON.parse(response.body)
      expect(json['questions']).to be_an(Array)
      expect(json['questions'].length).to eq(5)
    end

    it 'ページング対応' do
      get '/admin/questions.json', params: { page: 1, per_page: 2 }
      json = JSON.parse(response.body)
      expect(json['questions'].length).to eq(2)
      expect(json['pagination']).to include('total_count', 'page', 'per_page')
    end
  end

  describe 'GET /admin/questions/:id' do
    before { sign_in admin_user }

    it '質問詳細を表示する' do
      get "/admin/questions/#{question.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'JSON で質問と選択肢を返す' do
      create_list(:choice, 3, question: question)
      get "/admin/questions/#{question.id}.json"
      json = JSON.parse(response.body)
      expect(json['question']).to be_present
      expect(json['question']['choices']).to be_an(Array)
      expect(json['question']['choices'].length).to eq(3)
    end

    it '回答統計を含める' do
      create_list(:answer, 5, question: question)
      get "/admin/questions/#{question.id}.json"
      json = JSON.parse(response.body)
      expect(json['question']['stats']).to be_present
      expect(json['question']['stats']).to include('answer_count', 'answer_rate')
    end
  end

  describe 'POST /admin/questions' do
    before { sign_in admin_user }

    context '正常なパラメータ' do
      let(:valid_params) do
        {
          question: {
            title: '職場環境について',
            body: '職場環境は満足度はいかがですか？',
            question_type: 'text'
          }
        }
      end

      it '質問を作成する' do
        expect {
          post '/admin/questions', params: valid_params
        }.to change(Question, :count).by(1)
      end

      it 'HTTP 201 を返す' do
        post '/admin/questions', params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context '選択肢付き質問' do
      let(:valid_params) do
        {
          question: {
            title: '職場環境について',
            body: '職場環境は満足度はいかがですか？',
            question_type: 'choice',
            choices_attributes: [
              { text: '非常に満足' },
              { text: '満足' },
              { text: '普通' },
              { text: '不満' },
              { text: '非常に不満' }
            ]
          }
        }
      end

      it '質問と選択肢を作成する' do
        expect {
          post '/admin/questions', params: valid_params
        }.to change(Question, :count).by(1)
          .and change(Choice, :count).by(5)
      end
    end

    context 'バリデーション失敗' do
      it '空の title は拒否する' do
        params = {
          question: {
            title: '',
            body: 'テスト質問',
            question_type: 'text'
          }
        }

        expect {
          post '/admin/questions', params: params
        }.not_to change(Question, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /admin/questions/:id' do
    before { sign_in admin_user }

    it '質問を更新する' do
      patch "/admin/questions/#{question.id}", params: {
        question: { title: '新しいタイトル' }
      }
      question.reload
      expect(question.title).to eq('新しいタイトル')
    end

    it 'HTTP 200 を返す' do
      patch "/admin/questions/#{question.id}", params: {
        question: { theme: '新しいテーマ' }
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /admin/questions/:id' do
    before { sign_in admin_user }

    it '質問を削除する' do
      question_id = question.id
      expect {
        delete "/admin/questions/#{question_id}"
      }.to change(Question, :count).by(-1)
    end

    it 'HTTP 204 を返す' do
      delete "/admin/questions/#{question.id}"
      expect(response).to have_http_status(:no_content)
    end

    it '関連する回答も削除される' do
      create_list(:answer, 3, question: question)
      expect {
        delete "/admin/questions/#{question.id}"
      }.to change(Answer, :count).by(-3)
    end
  end

  describe 'Statistics' do
    before { sign_in admin_user }

    context '回答統計計算' do
      before do
        create_list(:answer, 5, question: question)
      end

      it '回答数を計算する' do
        get "/admin/questions/#{question.id}.json"
        json = JSON.parse(response.body)
        expect(json['question']['stats']['answer_count']).to eq(5)
      end

      it '回答率を計算する（訪問セッション数 / 回答数）' do
        # 仮に10セッション訪問、5回答
        get "/admin/questions/#{question.id}.json"
        json = JSON.parse(response.body)
        expect(json['question']['stats']['answer_rate']).to be_a(Float)
      end
    end

    context '選択肢別集計' do
      before do
        @choice1 = create(:choice, question: question, text: '満足')
        @choice2 = create(:choice, question: question, text: '不満')
        create_list(:answer, 3, question: question, choice: @choice1)
        create_list(:answer, 2, question: question, choice: @choice2)
      end

      it '選択肢ごとの回答数を集計する' do
        get "/admin/questions/#{question.id}.json"
        json = JSON.parse(response.body)
        choice_stats = json['question']['choice_stats']
        expect(choice_stats).to be_an(Array)
        expect(choice_stats.length).to eq(2)
      end

      it '選択肢の回答率を計算する' do
        get "/admin/questions/#{question.id}.json"
        json = JSON.parse(response.body)
        choice_stats = json['question']['choice_stats']
        # 選択肢1: 3/5 = 60%
        expect(choice_stats[0]['count']).to eq(3)
        expect(choice_stats[0]['percentage']).to be_within(0.1).of(60)
      end
    end
  end
end

RSpec.describe 'Admin::Choices', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:question) { create(:question, question_type: 'choice') }
  let(:choice) { create(:choice, question: question) }

  before { sign_in admin_user }

  describe 'POST /admin/questions/:question_id/choices' do
    it '選択肢を作成する' do
      expect {
        post "/admin/questions/#{question.id}/choices", params: {
          choice: { text: '新しい選択肢' }
        }
      }.to change(Choice, :count).by(1)
    end

    it 'HTTP 201 を返す' do
      post "/admin/questions/#{question.id}/choices", params: {
        choice: { text: '新しい選択肢' }
      }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /admin/questions/:question_id/choices/:id' do
    it '選択肢を更新する' do
      patch "/admin/questions/#{question.id}/choices/#{choice.id}", params: {
        choice: { text: '更新された選択肢' }
      }
      choice.reload
      expect(choice.text).to eq('更新された選択肢')
    end
  end

  describe 'DELETE /admin/questions/:question_id/choices/:id' do
    it '選択肢を削除する' do
      choice_id = choice.id
      expect {
        delete "/admin/questions/#{question.id}/choices/#{choice_id}"
      }.to change(Choice, :count).by(-1)
    end

    it '選択肢の回答も削除される' do
      create_list(:answer, 2, choice: choice)
      expect {
        delete "/admin/questions/#{question.id}/choices/#{choice.id}"
      }.to change(Answer, :count).by(-2)
    end
  end
end

RSpec.describe 'Admin Dashboard', type: :request do
  let(:admin_user) { create(:user, :admin) }

  before { sign_in admin_user }

  describe 'GET /admin/dashboard' do
    before do
      create_list(:question, 3)
    end

    it 'ダッシュボードを表示する' do
      get '/admin/dashboard'
      expect(response).to have_http_status(:ok)
    end

    it '質問一覧と統計を表示する' do
      get '/admin/dashboard.json'
      json = JSON.parse(response.body)
      expect(json['dashboard']).to be_present
      expect(json['dashboard']['questions']).to be_an(Array)
      expect(json['dashboard']['stats']).to be_present
    end

    it '全体統計を計算する' do
      get '/admin/dashboard.json'
      json = JSON.parse(response.body)
      stats = json['dashboard']['stats']
      expect(stats).to include('total_questions', 'total_answers')
    end
  end
end

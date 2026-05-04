require 'rails_helper'

RSpec.describe 'Member::Questions', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: admin_user.id) }

  before do
    # member_user を company に所属させる
    create(:company_member, company: company, user: member_user, role: :member)
  end

  describe 'アクセス制御' do
    context '未認証ユーザー' do
      it 'ログインページにリダイレクトされる' do
        get '/member/questions'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'adminユーザー' do
      before { sign_in admin_user }

      it 'adminダッシュボードにリダイレクトされる' do
        get '/member/questions'
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context 'memberユーザー' do
      before { sign_in member_user }

      it 'HTTP 200 を返す' do
        get '/member/questions'
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /member/questions (未回答タブ)' do
    before { sign_in member_user }

    let!(:published_q1) { create(:question, :published, company: company, title: '質問1') }
    let!(:published_q2) { create(:question, :published, company: company, title: '質問2') }
    let!(:draft_q) { create(:question, company: company, title: '下書き質問') }
    let!(:closed_q) { create(:question, :closed, company: company, title: 'クローズ質問') }

    context 'tab=unanswered（デフォルト）' do
      it '公開中で未回答の質問のみを返す' do
        get '/member/questions', params: { tab: 'unanswered' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('質問1')
        expect(response.body).to include('質問2')
        expect(response.body).not_to include('下書き質問')
      end

      it 'JSON フォーマットで質問リストを返す' do
        get '/member/questions.json', params: { tab: 'unanswered' }
        json = JSON.parse(response.body)
        expect(json['questions']).to be_an(Array)
        unanswered_titles = json['questions'].map { |q| q['title'] }
        expect(unanswered_titles).to include('質問1', '質問2')
        expect(unanswered_titles).not_to include('下書き質問')
      end
    end

    context 'tab=answered' do
      before do
        create(:answer, question: published_q1, user: member_user,
               session_id: "session_#{member_user.id}")
      end

      it '回答済みの質問のみを返す' do
        get '/member/questions.json', params: { tab: 'answered' }
        json = JSON.parse(response.body)
        titles = json['questions'].map { |q| q['title'] }
        expect(titles).to include('質問1')
        expect(titles).not_to include('質問2')
      end
    end

    context 'tab=closed' do
      it 'クローズ済みの質問のみを返す' do
        get '/member/questions.json', params: { tab: 'closed' }
        json = JSON.parse(response.body)
        titles = json['questions'].map { |q| q['title'] }
        expect(titles).to include('クローズ質問')
        expect(titles).not_to include('質問1')
      end
    end
  end

  describe 'GET /member/questions/:id (質問詳細 + 回答フォーム)' do
    before { sign_in member_user }

    let!(:question) { create(:question, :published, company: company, title: '詳細質問') }

    it 'HTTP 200 を返す' do
      get "/member/questions/#{question.id}"
      expect(response).to have_http_status(:ok)
    end

    it '質問タイトルが表示される' do
      get "/member/questions/#{question.id}"
      expect(response.body).to include('詳細質問')
    end

    context 'すでに回答済みの場合' do
      before do
        create(:answer, question: question, user: member_user,
               session_id: "session_#{member_user.id}")
      end

      it '回答済みと表示される' do
        get "/member/questions/#{question.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'クローズされた質問' do
      let!(:closed_q) { create(:question, :closed, company: company) }

      it 'ダッシュボードにリダイレクトされる' do
        get "/member/questions/#{closed_q.id}"
        expect(response).to redirect_to(member_dashboard_path)
      end
    end
  end
end

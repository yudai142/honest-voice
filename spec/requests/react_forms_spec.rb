require 'rails_helper'

RSpec.describe 'React Forms API', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:question) { create(:question, user: admin_user, status: 'published') }

  describe 'QuestionForm API' do
    describe 'POST /admin/questions - 質問作成' do
      context 'admin ユーザー' do
        before { sign_in admin_user }

        it '完全なパラメータで質問を作成する' do
          params = {
            question: {
              title: 'テスト質問',
              body: 'これはテスト質問です',
              question_type: 'choice',
              status: 'draft',
              choices_attributes: [
                { label: '選択肢1' },
                { label: '選択肢2' },
                { label: '選択肢3' }
              ]
            }
          }

          expect {
            post '/admin/questions', params: params
          }.to change(Question, :count).by(1)
          .and change(Choice, :count).by(3)

          expect(response).to have_http_status(:created)
        end

        it 'テキスト型質問を作成する' do
          params = {
            question: {
              title: 'テキスト質問',
              body: '自由記述質問です',
              question_type: 'text',
              status: 'draft'
            }
          }

          post '/admin/questions', params: params
          json = JSON.parse(response.body)
          
          expect(json['question']['question_type']).to eq('text')
          expect(json['question']['status']).to eq('draft')
        end

        it '選択肢型質問を作成する' do
          params = {
            question: {
              title: '選択肢質問',
              body: '複数選択',
              question_type: 'choice',
              status: 'draft',
              choices_attributes: [
                { label: 'Yes' },
                { label: 'No' }
              ]
            }
          }

          post '/admin/questions', params: params
          json = JSON.parse(response.body)
          
          expect(json['question']['question_type']).to eq('choice')
          expect(json['question']['choices']).to be_an(Array)
          expect(json['question']['choices'].length).to eq(2)
        end

        it 'レーティング型質問を作成する' do
          params = {
            question: {
              title: 'レーティング質問',
              body: '5段階評価',
              question_type: 'rating',
              status: 'draft',
              choices_attributes: [
                { label: '1点' },
                { label: '2点' },
                { label: '3点' },
                { label: '4点' },
                { label: '5点' }
              ]
            }
          }

          post '/admin/questions', params: params
          json = JSON.parse(response.body)
          
          expect(json['question']['question_type']).to eq('rating')
          expect(json['question']['choices'].length).to eq(5)
        end

        it 'バリデーションエラーを返す（title なし）' do
          params = {
            question: {
              body: 'タイトル なし',
              question_type: 'text'
            }
          }

          post '/admin/questions', params: params
          
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json['errors']).to be_an(Array)
        end

        it 'バリデーションエラーを返す（body なし）' do
          params = {
            question: {
              title: 'テスト質問',
              question_type: 'text'
            }
          }

          post '/admin/questions', params: params
          
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it '複数の選択肢を動的に追加できる' do
          params = {
            question: {
              title: '複数選択',
              body: '複数の選択肢テスト',
              question_type: 'choice',
              choices_attributes: (1..10).map { |i| { label: "選択肢#{i}" } }
            }
          }

          expect {
            post '/admin/questions', params: params
          }.to change(Choice, :count).by(10)
        end

        it 'JSON レスポンスに質問情報を含める' do
          params = {
            question: {
              title: 'テスト質問',
              body: 'テスト本文',
              question_type: 'text'
            }
          }

          post '/admin/questions', params: params
          json = JSON.parse(response.body)
          
          expect(json['question']).to include('id', 'title', 'body', 'question_type', 'status', 'created_at', 'updated_at')
        end
      end

      context 'member ユーザー' do
        before { sign_in member_user }

        it '403 Forbidden を返す' do
          params = {
            question: {
              title: 'テスト質問',
              body: '本文',
              question_type: 'text'
            }
          }

          post '/admin/questions', params: params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context '未認証ユーザー' do
        it 'ログインページへリダイレクト' do
          params = {
            question: {
              title: 'テスト質問',
              body: '本文',
              question_type: 'text'
            }
          }

          post '/admin/questions', params: params
          expect(response).to have_http_status(:found)
        end
      end
    end

    describe 'PATCH /admin/questions/:id - 質問編集' do
      context 'admin ユーザー' do
        before { sign_in admin_user }

        it '質問を更新する' do
          patch "/admin/questions/#{question.id}", params: {
            question: { title: '更新されたタイトル' }
          }

          question.reload
          expect(question.title).to eq('更新されたタイトル')
          expect(response).to have_http_status(:ok)
        end

        it '選択肢を追加する' do
          params = {
            question: {
              choices_attributes: [
                { label: '新しい選択肢1' },
                { label: '新しい選択肢2' }
              ]
            }
          }

          expect {
            patch "/admin/questions/#{question.id}", params: params
          }.to change(Choice, :count).by(2)
        end

        it '選択肢を削除する' do
          choice = create(:choice, question: question, label: '削除対象')
          choice_id = choice.id

          params = {
            question: {
              choices_attributes: [
                { id: choice_id, _destroy: true }
              ]
            }
          }

          expect {
            patch "/admin/questions/#{question.id}", params: params
          }.to change(Choice, :count).by(-1)
        end

        it 'JSON レスポンスで更新された質問を返す' do
          patch "/admin/questions/#{question.id}", params: {
            question: { title: '新しいタイトル' }
          }

          json = JSON.parse(response.body)
          expect(json['question']['title']).to eq('新しいタイトル')
        end
      end
    end
  end

  describe 'AnswerForm API' do
    describe 'POST /questions/:question_id/answers - 回答作成' do
      let(:text_question) { create(:question, :text_type, status: 'published') }
      let(:choice_question) { create(:question, :choice_type, status: 'published') }
      let(:rating_question) { create(:question, :rating_type, status: 'published') }

      context 'テキスト型質問への回答' do
        it '自由記述回答を作成する' do
          params = {
            answer: {
              body: 'これはテスト回答です',
              session_id: 'test_session_123'
            }
          }

          expect {
            post "/questions/#{text_question.id}/answers", params: params
          }.to change(Answer, :count).by(1)

          expect(response).to have_http_status(:created)
        end

        it '空の回答は拒否する' do
          params = {
            answer: {
              body: '',
              session_id: 'test_session_123'
            }
          }

          expect {
            post "/questions/#{text_question.id}/answers", params: params
          }.not_to change(Answer, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'JSON レスポンスで作成された回答を返す' do
          params = {
            answer: {
              body: 'テスト回答',
              session_id: 'test_session_123'
            }
          }

          post "/questions/#{text_question.id}/answers", params: params
          json = JSON.parse(response.body)
          
          expect(json['answer']).to include('id', 'body', 'created_at')
          expect(json['answer']['body']).to eq('テスト回答')
        end
      end

      context '選択肢型質問への回答' do
        let(:choice1) { create(:choice, question: choice_question, label: '選択肢1') }
        let(:choice2) { create(:choice, question: choice_question, label: '選択肢2') }

        it '選択肢を選んで回答する' do
          params = {
            answer: {
              choice_id: choice1.id,
              session_id: 'test_session_456'
            }
          }

          expect {
            post "/questions/#{choice_question.id}/answers", params: params
          }.to change(Answer, :count).by(1)

          answer = Answer.last
          expect(answer.choice_id).to eq(choice1.id)
        end

        it 'choice_id がない場合は拒否する' do
          params = {
            answer: {
              session_id: 'test_session_456'
            }
          }

          expect {
            post "/questions/#{choice_question.id}/answers", params: params
          }.not_to change(Answer, :count)
        end

        it 'JSON レスポンスで choice_id を含める' do
          params = {
            answer: {
              choice_id: choice1.id,
              session_id: 'test_session_456'
            }
          }

          post "/questions/#{choice_question.id}/answers", params: params
          json = JSON.parse(response.body)
          
          expect(json['answer']['choice_id']).to eq(choice1.id)
        end
      end

      context 'レーティング型質問への回答' do
        let(:rating1) { create(:choice, question: rating_question, label: '1点') }
        let(:rating5) { create(:choice, question: rating_question, label: '5点') }

        it '1～5のレーティングを選んで回答する' do
          params = {
            answer: {
              choice_id: rating5.id,
              session_id: 'test_session_789'
            }
          }

          expect {
            post "/questions/#{rating_question.id}/answers", params: params
          }.to change(Answer, :count).by(1)
        end

        it '複数の回答を同じセッションで作成できる' do
          params1 = {
            answer: {
              choice_id: rating1.id,
              session_id: 'same_session'
            }
          }

          params2 = {
            answer: {
              body: '異なる質問への回答',
              session_id: 'same_session'
            }
          }

          expect {
            post "/questions/#{rating_question.id}/answers", params: params1
            post "/questions/#{text_question.id}/answers", params: params2
          }.to change(Answer, :count).by(2)
        end
      end

      context '重複回答チェック' do
        it '同じセッション ID で同じ質問には重複回答を作成しない' do
          session_id = 'duplicate_test_session'

          params = {
            answer: {
              body: '最初の回答',
              session_id: session_id
            }
          }

          post "/questions/#{text_question.id}/answers", params: params
          
          params2 = {
            answer: {
              body: '重複した回答',
              session_id: session_id
            }
          }

          expect {
            post "/questions/#{text_question.id}/answers", params: params2
          }.not_to change(Answer, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'session_id ハッシング' do
        it 'session_id_hash に SHA256 ハッシュを保存する' do
          session_id = 'test_session_hash'
          params = {
            answer: {
              body: 'テスト回答',
              session_id: session_id
            }
          }

          post "/questions/#{text_question.id}/answers", params: params
          answer = Answer.last
          
          expected_hash = Digest::SHA256.hexdigest(session_id)
          expect(answer.session_id_hash).to eq(expected_hash)
        end
      end
    end

    describe 'GET /questions/:question_id/answers - 回答一覧' do
      let(:question) { create(:question, :text_type, status: 'published') }

      context '回答取得' do
        before do
          create_list(:answer, 5, question: question)
        end

        it '質問の回答一覧を取得する' do
          get "/questions/#{question.id}/answers"
          
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          
          expect(json['answers']).to be_an(Array)
          expect(json['answers'].length).to eq(5)
        end

        it 'JSON で session_id のハッシュを含める' do
          get "/questions/#{question.id}/answers.json"
          json = JSON.parse(response.body)
          
          json['answers'].each do |answer|
            expect(answer).to include('id', 'body')
            expect(answer).not_to include('session_id_hash')
            expect(answer).not_to include('session_id')
          end
        end

        it 'ページネーション対応' do
          get "/questions/#{question.id}/answers.json?per_page=2"
          json = JSON.parse(response.body)
          
          expect(json['answers'].length).to eq(2)
          expect(json['pagination']).to include('total_count', 'per_page', 'page')
        end
      end
    end
  end

  describe '動的フォーム生成 API' do
    describe 'GET /admin/form-template - フォームテンプレート' do
      context 'admin ユーザー' do
        before { sign_in admin_user }

        it 'テキスト型フォームテンプレートを返す' do
          get '/admin/form-template.json?question_type=text'
          
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          
          expect(json['template']['question_type']).to eq('text')
          expect(json['template']['fields']).to be_an(Array)
        end

        it '選択肢型フォームテンプレートを返す' do
          get '/admin/form-template.json?question_type=choice'
          
          json = JSON.parse(response.body)
          expect(json['template']['question_type']).to eq('choice')
          choices_field = json['template']['fields'].find { |f| f['name'] == 'choices_attributes' }
          expect(choices_field).to be_present
        end

        it 'レーティング型フォームテンプレートを返す' do
          get '/admin/form-template.json?question_type=rating'
          
          json = JSON.parse(response.body)
          expect(json['template']['question_type']).to eq('rating')
        end
      end
    end
  end

  describe 'フォームバリデーション API' do
    describe 'POST /admin/validate-question - 質問バリデーション' do
      context 'admin ユーザー' do
        before { sign_in admin_user }

        it '有効な質問データを検証する' do
          params = {
            question: {
              title: 'テスト質問',
              body: 'テスト本文',
              question_type: 'text'
            }
          }

          post '/admin/validate-question', params: params
          json = JSON.parse(response.body)
          
          expect(json['valid']).to be true
        end

        it 'バリデーションエラーを返す' do
          params = {
            question: {
              title: '',
              body: '',
              question_type: ''
            }
          }

          post '/admin/validate-question', params: params
          json = JSON.parse(response.body)
          
          expect(json['valid']).to be false
          expect(json['errors']).to be_an(Array)
        end

        it 'フィールド単位のエラーを返す' do
          params = {
            question: {
              title: '',
              body: 'テスト本文',
              question_type: 'text'
            }
          }

          post '/admin/validate-question', params: params
          json = JSON.parse(response.body)
          
          expect(json['errors']).to include(hash_including('field' => 'title'))
        end
      end
    end

    describe 'POST /validate-answer - 回答バリデーション' do
      let(:question) { create(:question, :text_type) }

      it '有効な回答データを検証する' do
        params = {
          question_id: question.id,
          answer: {
            body: 'テスト回答',
            session_id: 'test_session'
          }
        }

        post '/validate-answer', params: params
        json = JSON.parse(response.body)
        
        expect(json['valid']).to be true
      end

      it 'バリデーションエラーを返す' do
        params = {
          question_id: question.id,
          answer: {
            body: '',
            session_id: ''
          }
        }

        post '/validate-answer', params: params
        json = JSON.parse(response.body)
        
        expect(json['valid']).to be false
      end
    end
  end
end

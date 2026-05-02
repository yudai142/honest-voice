require 'rails_helper'

describe 'Admin Statistics' do
  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  
  # テキスト型質問
  let(:text_question) do
    create(:question, :text_type, user: admin_user, status: 'published')
  end

  # 選択肢型質問
  let(:choice_question) do
    create(:question, :choice_type, user: admin_user, status: 'published')
  end

  # レーティング型質問
  let(:rating_question) do
    create(:question, :rating_type, user: admin_user, status: 'published')
  end

  describe 'GET /admin/questions/:id/statistics' do
    context 'admin ユーザー' do
      before { sign_in admin_user }

      describe 'テキスト型質問の統計表示' do
        before do
          # テキスト回答を複数作成
          create_list(:answer, 5, question: text_question, body: 'ポジティブなコメント')
          create_list(:answer, 3, question: text_question, body: '改善要望です')
          create_list(:answer, 2, question: text_question, body: 'その他')
        end

        it 'HTTP 200 を返す' do
          get "/admin/questions/#{text_question.id}/statistics"
          expect(response).to have_http_status(:ok)
        end

        it '自由記述回答一覧を表示する' do
          get "/admin/questions/#{text_question.id}/statistics"
          expect(response.body).to include('ポジティブなコメント')
          expect(response.body).to include('改善要望です')
          expect(response.body).to include('その他')
        end

        it 'JSON で回答一覧を返す' do
          get "/admin/questions/#{text_question.id}/statistics.json"
          json = JSON.parse(response.body)
          expect(json['answers']).to be_an(Array)
          expect(json['answers'].length).to eq(10)
          expect(json['answers'].first).to include('body', 'created_at')
        end

        it '回答総数を含める' do
          get "/admin/questions/#{text_question.id}/statistics.json"
          json = JSON.parse(response.body)
          expect(json['stats']['total_answers']).to eq(10)
        end
      end

      describe '選択肢型質問の統計表示' do
        before do
          # 選択肢を作成
          @choice1 = create(:choice, question: choice_question, label: '非常に満足')
          @choice2 = create(:choice, question: choice_question, label: '満足')
          @choice3 = create(:choice, question: choice_question, label: '普通')
          
          # 選択肢回答を作成
          create_list(:answer, 15, question: choice_question, choice: @choice1)
          create_list(:answer, 25, question: choice_question, choice: @choice2)
          create_list(:answer, 10, question: choice_question, choice: @choice3)
        end

        it 'HTTP 200 を返す' do
          get "/admin/questions/#{choice_question.id}/statistics"
          expect(response).to have_http_status(:ok)
        end

        it '選択肢統計データを表示する' do
          get "/admin/questions/#{choice_question.id}/statistics"
          expect(response.body).to include('非常に満足')
          expect(response.body).to include('満足')
          expect(response.body).to include('普通')
        end

        it 'JSON で選択肢統計を返す' do
          get "/admin/questions/#{choice_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          expect(json['choice_stats']).to be_an(Array)
          expect(json['choice_stats'].length).to eq(3)
          
          # 各選択肢のデータを確認
          stats = json['choice_stats']
          expect(stats.map { |s| s['label'] }).to include('非常に満足', '満足', '普通')
          expect(stats.map { |s| s['count'] }).to include(15, 25, 10)
        end

        it 'JSON に回答率（パーセンテージ）を含める' do
          get "/admin/questions/#{choice_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          stats = json['choice_stats']
          total = 50
          
          stats.each do |stat|
            expected_rate = (stat['count'].to_f / total * 100).round(2)
            expect(stat['rate']).to eq(expected_rate)
          end
        end

        it '棒グラフ用データ形式を返す' do
          get "/admin/questions/#{choice_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          expect(json['charts']).to include('bar_data', 'pie_data')
          expect(json['charts']['bar_data']).to be_an(Array)
          expect(json['charts']['pie_data']).to be_an(Array)
        end

        it '円グラフ用データ形式を返す' do
          get "/admin/questions/#{choice_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          pie_data = json['charts']['pie_data']
          expect(pie_data.first).to include('name', 'y')
        end

        it 'グラフカラーテーマを含める' do
          get "/admin/questions/#{choice_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          expect(json['charts']).to include('colors')
          expect(json['charts']['colors']).to be_an(Array)
        end
      end

      describe 'レーティング型質問の統計表示' do
        before do
          # レーティング選択肢を作成（1-5）
          (1..5).each do |i|
            choice = create(:choice, question: rating_question, label: "#{i}点")
            # 回答分布：5点が最多、1点が最小
            create_list(:answer, (6 - i) * 5, question: rating_question, choice: choice)
          end
        end

        it 'JSON でレーティング分布を返す' do
          get "/admin/questions/#{rating_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          expect(json['choice_stats'].length).to eq(5)
          # 5点を確認（最多）
          five_star = json['choice_stats'].find { |s| s['label'] == '5点' }
          expect(five_star['count']).to eq(25)
        end

        it 'ユーザーの平均レーティングを計算する' do
          get "/admin/questions/#{rating_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          # 平均値の計算確認
          # 5点x25 + 4点x20 + 3点x15 + 2点x10 + 1点x5 = 255 / 75 = 3.4
          expect(json['stats']['average_rating']).to be_present
          expect(json['stats']['average_rating']).to be_a(Float)
        end
      end

      describe '回答がない質問' do
        it '回答なしでも統計ページを表示する' do
          get "/admin/questions/#{text_question.id}/statistics"
          expect(response).to have_http_status(:ok)
        end

        it 'JSON で空の統計を返す' do
          get "/admin/questions/#{text_question.id}/statistics.json"
          json = JSON.parse(response.body)
          
          expect(json['stats']['total_answers']).to eq(0)
          expect(json['answers']).to eq([])
        end
      end
    end

    context 'member ユーザー' do
      before { sign_in member_user }

      it '403 Forbidden を返す' do
        get "/admin/questions/#{text_question.id}/statistics"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context '未認証ユーザー' do
      it '302 Found（ログインページへリダイレクト）を返す' do
        get "/admin/questions/#{text_question.id}/statistics"
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'Statistics コンポーネント' do
    before { sign_in admin_user }

    describe 'React コンポーネント Statistics' do
      it 'props として question_id を受け取る' do
        # コンポーネントレンダリングテストは別ファイルで実施
        pending 'React テスト（test/ ディレクトリ）で実施'
      end

      it 'JSON 応答から棒グラフデータを生成する' do
        pending 'React テスト（test/ ディレクトリ）で実施'
      end

      it 'JSON 応答から円グラフデータを生成する' do
        pending 'React テスト（test/ ディレクトリ）で実施'
      end

      it '自由記述回答を一覧表示する' do
        pending 'React テスト（test/ ディレクトリ）で実施'
      end
    end
  end

  describe 'グラフカスタマイズ' do
    before { sign_in admin_user }

    it 'カラーテーマが DaisyUI のカラーパレットに準拠' do
      create(:choice, question: choice_question, label: '選択肢1')
      create(:choice, question: choice_question, label: '選択肢2')
      
      create(:answer, question: choice_question, choice: choice_question.choices.first)
      create(:answer, question: choice_question, choice: choice_question.choices.last)
      
      get "/admin/questions/#{choice_question.id}/statistics.json"
      json = JSON.parse(response.body)
      
      # DaisyUI カラーが含まれていることを確認
      colors = json['charts']['colors']
      expect(colors).to be_an(Array)
      expect(colors.first).to match(/^#[0-9a-f]{6}$/i)
    end

    it 'グラフラベルが正しく設定される' do
      create(:choice, question: choice_question, label: '重要な選択肢')
      create(:answer, question: choice_question, choice: choice_question.choices.first)
      
      get "/admin/questions/#{choice_question.id}/statistics.json"
      json = JSON.parse(response.body)
      
      labels = json['charts']['bar_data'].map { |d| d['label'] }
      expect(labels).to include('重要な選択肢')
    end
  end

  describe 'エクスポート機能（オプション）' do
    before { sign_in admin_user }

    it 'CSV をダウンロードできる（実装時）' do
      pending 'CSV エクスポート機能は Issue #8.1 で実装予定'
    end

    it 'PDF をダウンロードできる（実装時）' do
      pending 'PDF エクスポート機能は Issue #8.2 で実装予定'
    end
  end
end

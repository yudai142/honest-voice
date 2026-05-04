require 'rails_helper'

RSpec.describe 'Seed data' do
  before do
    # データベースをクリアしてから seed を実行
    User.delete_all
    Question.delete_all
    Choice.delete_all
    Answer.delete_all
    AnswerToken.delete_all
    
    # Seed スクリプト読み込みと実行
    load Rails.root.join('db', 'seeds.rb')
  end

  describe 'Users' do
    it '管理者ユーザーが1名作成される' do
      admin_user = User.find_by(role: :admin)
      expect(admin_user).not_to be_nil
      expect(admin_user.admin?).to be true
    end

    it '従業員ユーザーが3名作成される' do
      member_users = User.where(role: :member)
      expect(member_users.count).to eq(3)
      expect(member_users.all?(&:member?)).to be true
    end

    it 'すべてのユーザーが有効なメールアドレスを持つ' do
      expect(User.all.all? { |user| user.email.present? && user.email.include?('@') }).to be true
    end

    it 'ユーザー数が4名である' do
      expect(User.count).to eq(4)
    end
  end

  describe 'Questions' do
    it 'サンプル質問が複数作成される' do
      expect(Question.count).to be > 0
    end

    it 'テキスト型質問が存在する' do
      text_questions = Question.where(question_type: :text)
      expect(text_questions.exists?).to be true
    end

    it '選択肢型質問が存在する' do
      choice_questions = Question.where(question_type: :choice)
      expect(choice_questions.exists?).to be true
    end

    it 'レーティング型質問が存在する' do
      rating_questions = Question.where(question_type: :rating)
      expect(rating_questions.exists?).to be true
    end

    it 'すべての質問が admin ユーザーに属する' do
      admin_user = User.find_by(role: :admin)
      expect(Question.all.all? { |q| q.user_id == admin_user.id }).to be true
    end

    it 'すべての質問が title を持つ' do
      expect(Question.all.all? { |q| q.title.present? }).to be true
    end

    it 'すべての質問が body を持つ' do
      expect(Question.all.all? { |q| q.body.present? }).to be true
    end

    it 'すべての質問が published status である' do
      expect(Question.all.all? { |q| q.published? }).to be true
    end
  end

  describe 'Choices' do
    it '選択肢型質問に複数の選択肢が作成される' do
      choice_questions = Question.where(question_type: :choice)
      choice_questions.each do |question|
        expect(question.choices.count).to be > 0
      end
    end

    it 'テキスト型質問には選択肢がない' do
      text_questions = Question.where(question_type: :text)
      text_questions.each do |question|
        expect(question.choices.count).to eq(0)
      end
    end
  end
end

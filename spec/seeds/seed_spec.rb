require 'rails_helper'

RSpec.describe 'Seed data' do
  before do
    # データベースをクリアしてから seed を実行（外部キー制約を考慮した削除順序）
    AdminReply.delete_all
    AnswerToken.delete_all
    Answer.delete_all
    Choice.delete_all
    QuestionAnalysis.delete_all rescue nil
    QuestionTarget.delete_all rescue nil
    RecurringSchedule.delete_all rescue nil
    Question.delete_all
    InviteToken.delete_all rescue nil
    Department.delete_all rescue nil
    CompanyMember.delete_all rescue nil
    QuestionTemplate.delete_all rescue nil
    Company.delete_all rescue nil
    User.delete_all

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

  describe 'Companies' do
    it '会社グループが2社作成される' do
      expect(Company.count).to eq(2)
    end

    it 'すべての会社が名前を持つ' do
      expect(Company.all.all? { |c| c.name.present? }).to be true
    end

    it 'すべての会社が所有者を持つ' do
      expect(Company.all.all? { |c| c.owner_id.present? }).to be true
    end
  end

  describe 'Departments' do
    it '部署が4種類作成される' do
      expect(Department.count).to eq(4)
    end

    it 'すべての部署が会社に属する' do
      expect(Department.all.all? { |d| d.company_id.present? }).to be true
    end

    it 'すべての部署が名前を持つ' do
      expect(Department.all.all? { |d| d.name.present? }).to be true
    end

    it '各会社が少なくとも1つ以上の部署を持つ' do
      Company.all.each do |company|
        expect(company.departments.count).to be >= 1
      end
    end
  end

  describe 'QuestionTemplates' do
    it 'テンプレートが各企業に8件ずつ作成される（全16件）' do
      expect(QuestionTemplate.count).to eq(16)
    end

    it 'すべてのテンプレートが会社に属する' do
      expect(QuestionTemplate.all.all? { |t| t.company_id.present? }).to be true
    end

    it 'すべてのテンプレートが名前を持つ' do
      expect(QuestionTemplate.all.all? { |t| t.name.present? }).to be true
    end

    it 'すべてのテンプレートが template_type を持つ' do
      expect(QuestionTemplate.all.all? { |t| t.template_type.present? }).to be true
    end

    it 'すべてのテンプレートが questions_data を持つ' do
      expect(QuestionTemplate.all.all? { |t| t.questions_data.present? }).to be true
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

    it 'すべての質問がデモ企業に属する' do
      demo_company = Company.find_by(name: 'Honest Voice デモ企業')
      expect(Question.all.all? { |q| q.company_id == demo_company.id }).to be true
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

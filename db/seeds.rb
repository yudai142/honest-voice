# Seed データ・初期化スクリプト

# 既存データをクリア（外部キー制約を考慮した削除順序）
AdminReply.delete_all
AnswerToken.delete_all
Answer.delete_all
Choice.delete_all
QuestionAnalysis.delete_all
QuestionTarget.delete_all
RecurringSchedule.delete_all
Question.delete_all
InviteToken.delete_all
Department.delete_all
QuestionTemplate.delete_all
CompanyMember.delete_all
Company.delete_all
User.delete_all

# IDカウンターをリセット
if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
  ActiveRecord::Base.connection.reset_pk_sequence!(:users)
  ActiveRecord::Base.connection.reset_pk_sequence!(:companies)
  ActiveRecord::Base.connection.reset_pk_sequence!(:company_members)
  ActiveRecord::Base.connection.reset_pk_sequence!(:departments)
  ActiveRecord::Base.connection.reset_pk_sequence!(:question_templates)
  ActiveRecord::Base.connection.reset_pk_sequence!(:questions)
  ActiveRecord::Base.connection.reset_pk_sequence!(:choices)
  ActiveRecord::Base.connection.reset_pk_sequence!(:answers)
  ActiveRecord::Base.connection.reset_pk_sequence!(:answer_tokens)
end

puts '=== Seed データ生成を開始 ==='

# ==========================================
# 1. 管理者ユーザー作成
# ==========================================
admin = User.create!(
  email: 'admin@honest-voice.local',
  password: 'HonestVoice123!',
  password_confirmation: 'HonestVoice123!',
  role: :admin
)
puts "✓ 管理者ユーザー作成: #{admin.email}"

# ==========================================
# 2. 従業員ユーザー作成（3名）
# ==========================================
member_emails = [
  'member1@honest-voice.local',
  'member2@honest-voice.local',
  'member3@honest-voice.local'
]

members = member_emails.map do |email|
  User.create!(
    email: email,
    password: 'HonestVoice123!',
    password_confirmation: 'HonestVoice123!',
    role: :member
  )
end
puts "✓ 従業員ユーザー作成: #{members.count}名"

# ==========================================
# 3. 会社グループ作成（2社）
# ==========================================
companies = []

company1 = Company.create!(
  name: 'Honest Voice デモ企業',
  description: 'フィードバック収集プラットフォームのデモ企業',
  owner_id: admin.id,
  visibility: :company_private
)
companies << company1
puts "✓ 会社グループ作成: #{company1.name}"

company2 = Company.create!(
  name: 'テクノロジー企業グループ',
  description: '技術系の企業グループ向けデモ',
  owner_id: admin.id,
  visibility: :company_private
)
companies << company2
puts "✓ 会社グループ作成: #{company2.name}"

# メンバーを企業に追加
members.each do |member|
  company1.company_members.create!(user_id: member.id, role: :member)
  company2.company_members.create!(user_id: member.id, role: :member)
end
puts "✓ 従業員3名を両企業に追加"

# ==========================================
# 4. 部署作成（4種、各企業で重複）
# ==========================================
department_names = ['営業部', '企画部', '開発部', '支援部']

companies.each do |company|
  department_names.each do |dept_name|
    Department.create!(
      company_id: company.id,
      name: dept_name
    )
  end
end
puts "✓ 部署作成: 各企業に #{department_names.count}種類（全#{Department.count}件）"

# ==========================================
# 5. 質問テンプレート作成（8件）
# ==========================================
template_configs = [
  { name: '月次フィードバック（総合）', type: :monthly, questions: [
    { title: '今月の総括', body: '今月の業務全体についての評価をお願いします' },
    { title: 'チーム協力度', body: 'チーム内の協力度をお答えください' }
  ]},
  { name: '月次フィードバック（部門別）', type: :monthly, questions: [
    { title: '部門の成果', body: '部門の今月の成果について教えてください' }
  ]},
  { name: '四半期目標進捗確認', type: :quarterly, questions: [
    { title: '進捗率', body: '四半期目標の進捗率をお答えください' },
    { title: '課題と対応', body: '現在の課題と対応策をお教えください' }
  ]},
  { name: '四半期評価アンケート', type: :quarterly, questions: [
    { title: '自己評価', body: '四半期間の自己評価をお願いします' }
  ]},
  { name: '年間成長度確認', type: :yearly, questions: [
    { title: '年間成長', body: '1年間の成長について教えてください' },
    { title: '来年への抱負', body: '来年への抱負やビジョンをお聞かせください' }
  ]},
  { name: '年間総括アンケート', type: :yearly, questions: [
    { title: '年間評価', body: '1年間の業務評価をお答えください' }
  ]},
  { name: '組織風土調査', type: :quarterly, questions: [
    { title: '職場の雰囲気', body: '職場の雰囲気についてお答えください' }
  ]},
  { name: '顧客満足度調査', type: :monthly, questions: [
    { title: '顧客対応品質', body: '顧客への対応品質について教えてください' }
  ]}
]

template_count = 0
companies.each do |company|
  template_configs.each do |config|
    template = QuestionTemplate.create!(
      company_id: company.id,
      name: config[:name],
      template_type: config[:type],
      questions_data: config[:questions].to_json
    )
    template_count += 1
  end
end
puts "✓ 質問テンプレート作成: #{template_count}件（各企業に #{template_configs.count}件）"

# デモ企業の別名定義
demo_company = company1

# ==========================================
# 4. サンプル質問作成
# ==========================================

# テキスト型質問
q1 = Question.create!(
  company_id: demo_company.id,
  title: '今月で改善されたと感じたことを教えてください',
  body: '組織の改善に繋がった内容があれば、具体的にお書きください',
  question_type: :text,
  status: :published,
  deadline: 1.week.from_now
)
puts "✓ テキスト型質問作成: #{q1.title}"

# 選択肢型質問
q2 = Question.create!(
  company_id: demo_company.id,
  title: 'あなたの職場環境について評価してください',
  body: 'チームの雰囲気をお選びください',
  question_type: :choice,
  status: :published,
  deadline: 10.days.from_now
)

# 選択肢を追加
choice_labels = ['非常に良好', '良好', '普通', '改善が必要', '大きな問題がある']
choice_labels.each do |label|
  Choice.create!(
    question_id: q2.id,
    label: label
  )
end
puts "✓ 選択肢型質問作成: #{q2.title}（選択肢数: #{q2.choices.count}）"

# レーティング型質問
q3 = Question.create!(
  company_id: demo_company.id,
  title: '今月の社内コミュニケーション満足度を教えてください',
  body: '1〜5の範囲で評価してください（1: 非常に不満、5: 非常に満足）',
  question_type: :rating,
  status: :published,
  deadline: 5.days.from_now
)
puts "✓ レーティング型質問作成: #{q3.title}"

# テキスト型質問（2つ目）
q4 = Question.create!(
  company_id: demo_company.id,
  title: '次年度の会社方針についてのご意見をお聞かせください',
  body: '会社の方向性や戦略についての率直なご意見をお願いします',
  question_type: :text,
  status: :published,
  deadline: 15.days.from_now
)
puts "✓ テキスト型質問作成: #{q4.title}"

# ==========================================
# 完了メッセージ
# ==========================================
puts "\n✅ Seed データ生成完了！"
puts "  - ユーザー数: #{User.count}名（管理者: 1, 従業員: 3）"
puts "  - 企業数: #{Company.count}社"
puts "  - 部署数: #{Department.count}個（各企業4種類）"
puts "  - 質問テンプレート数: #{QuestionTemplate.count}件"
puts "    - 月次: #{QuestionTemplate.where(template_type: :monthly).count}件"
puts "    - 四半期: #{QuestionTemplate.where(template_type: :quarterly).count}件"
puts "    - 年間: #{QuestionTemplate.where(template_type: :yearly).count}件"
puts "  - 質問数: #{Question.count}件"
puts "    - テキスト型: #{Question.where(question_type: :text).count}件"
puts "    - 選択肢型: #{Question.where(question_type: :choice).count}件"
puts "    - レーティング型: #{Question.where(question_type: :rating).count}件"
puts "  - 選択肢数: #{Choice.count}個"

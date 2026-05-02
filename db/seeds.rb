# Seed データ・初期化スクリプト

# 既存データをクリア
User.delete_all
Question.delete_all
Choice.delete_all
Answer.delete_all
AnswerToken.delete_all

# IDカウンターをリセット
if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
  ActiveRecord::Base.connection.reset_pk_sequence!(:users)
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
# 3. サンプル質問作成
# ==========================================

# テキスト型質問
q1 = Question.create!(
  user_id: admin.id,
  title: '今月で改善されたと感じたことを教えてください',
  body: '組織の改善に繋がった内容があれば、具体的にお書きください',
  question_type: :text,
  status: :published,
  deadline: 1.week.from_now
)
puts "✓ テキスト型質問作成: #{q1.title}"

# 選択肢型質問
q2 = Question.create!(
  user_id: admin.id,
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
  user_id: admin.id,
  title: '今月の社内コミュニケーション満足度を教えてください',
  body: '1〜5の範囲で評価してください（1: 非常に不満、5: 非常に満足）',
  question_type: :rating,
  status: :published,
  deadline: 5.days.from_now
)
puts "✓ レーティング型質問作成: #{q3.title}"

# テキスト型質問（2つ目）
q4 = Question.create!(
  user_id: admin.id,
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
puts "  - 質問数: #{Question.count}件"
puts "    - テキスト型: #{Question.where(question_type: :text).count}件"
puts "    - 選択肢型: #{Question.where(question_type: :choice).count}件"
puts "    - レーティング型: #{Question.where(question_type: :rating).count}件"
puts "  - 選択肢数: #{Choice.count}個"

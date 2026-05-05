# frozen_string_literal: true

class RecurringJob < ApplicationJob
  queue_as :default

  def perform
    enqueue_deadline_reminders(3)
    enqueue_deadline_reminders(1)

    RecurringSchedule.active_schedules.due_today.find_each do |schedule|
      process_schedule(schedule)
      schedule.mark_as_run
    end
  end

  private

  def process_schedule(schedule)
    # 前回の質問がある場合は分析をキック
    AnalysisJob.perform_later(schedule.question_id) if schedule.question_id.present?

    # テンプレートがある場合は新しい質問を作成
    return unless schedule.question_template_id.present?

    template = schedule.question_template
    questions = template.questions_array

    questions.each do |q_data|
      # ターゲットスコープに応じた質問作成
      if schedule.target_scope == 'department'
        schedule.company.departments.find_each do |dept|
          create_question_from_template(schedule.company, dept, q_data, schedule)
        end
      else
        create_question_from_template(schedule.company, nil, q_data, schedule)
      end
    end
  end

  def create_question_from_template(company, department, q_data, schedule)
    question = company.questions.create!(
      title: "#{q_data['title']} (#{Date.today.strftime('%Y/%m')})",
      body: q_data['body'],
      question_type: q_data['question_type'] || 'text',
      status: 'published',
      deadline: 1.week.from_now,
      department: department
    )

    # テンプレートに選択肢がある場合は作成
    if q_data['choices'].is_a?(Array)
      q_data['choices'].each do |choice_text|
        question.choices.create!(label: choice_text)
      end
    end

    # 最新の質問IDをスケジュールに紐付け（複数の場合は最後の一つ、または設計次第）
    schedule.update(question_id: question.id)
  end

  def enqueue_deadline_reminders(days_before_deadline)
    target_date = days_before_deadline.days.from_now.to_date
    range = target_date.beginning_of_day..target_date.end_of_day

    Question.published.where(deadline: range).find_each do |question|
      ReminderJob.perform_later(question.id, days_before_deadline)
    end
  end
end